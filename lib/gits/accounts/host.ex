defmodule Gits.Accounts.Host do
  alias Gits.Storefront
  alias Gits.Storefront.{Event, Order}
  alias Gits.PaystackApi
  alias Gits.Accounts
  alias Gits.Accounts.{Role, User}

  use Ash.Resource,
    domain: Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: Ash.Policy.Authorizer,
    extensions: [AshArchival.Resource, AshStateMachine, AshPaperTrail.Resource]

  postgres do
    repo Gits.Repo
    table "hosts"
  end

  state_machine do
    initial_states [:pending]
    default_initial_state :pending

    transitions do
      transition :verify, from: :pending, to: :verified
      transition :suspend, from: [:risky, :pending, :verified], to: :suspended
      transition :restore, from: :suspended, to: :risky
    end
  end

  paper_trail do
    change_tracking_mode :changes_only
    store_action_name? true
    ignore_attributes [:created_at, :updated_at]
  end

  actions do
    defaults [:read, :destroy, update: :*]

    create :create do
      primary? true
      accept [:name, :logo]

      argument :owner, :map do
        allow_nil? false
      end

      argument :role, :map do
        allow_nil? false
      end

      change manage_relationship(:owner, type: :append)
      change manage_relationship(:role, :roles, type: :create)
      change set_attribute(:handle, &Nanoid.generate/0)
    end

    update :details do
      accept [:name]
    end

    update :verify do
      change transition_state(:verified)
      change atomic_update(:verified_at, expr(fragment("now()")))
    end

    update :suspend do
    end

    update :restore do
    end

    update :add_event do
      argument :event, :map, allow_nil?: false
      change manage_relationship(:event, :events, type: :create)
    end

    update :paystack_subaccount do
      require_atomic? false

      argument :paystack_business_name, :string, allow_nil?: false
      argument :paystack_settlement_bank, :string, allow_nil?: false
      argument :paystack_account_number, :string, allow_nil?: false

      change fn changeset, _ ->
        business_name = Ash.Changeset.get_argument(changeset, :paystack_business_name)
        account_number = Ash.Changeset.get_argument(changeset, :paystack_account_number)
        settlement_bank = Ash.Changeset.get_argument(changeset, :paystack_settlement_bank)

        if changeset.data.paystack_subaccount_code do
          Ash.Changeset.before_transaction(changeset, fn changeset ->
            code = changeset.data.paystack_subaccount_code

            PaystackApi.update_subaccount(
              code,
              business_name,
              account_number,
              settlement_bank,
              :cache
            )

            changeset
          end)
        else
          Ash.Changeset.before_transaction(changeset, fn changeset ->
            PaystackApi.create_subaccount(business_name, account_number, settlement_bank)
            |> case do
              {:ok, subaccount} ->
                Ash.Changeset.force_change_attribute(
                  changeset,
                  :paystack_subaccount_code,
                  subaccount.subaccount_code
                )
            end
          end)
        end
      end
    end
  end

  policies do
    policy action(:read) do
      authorize_if always()
    end

    policy action(:create) do
      authorize_if actor_present()
    end

    policy action(:update) do
      authorize_if actor_present()
    end

    policy action(:paystack_subaccount) do
      authorize_if expr(roles.user.id == ^actor(:id))
    end

    policy action(:paystack_subaccount) do
      authorize_if expr(roles.type in [:owner])
    end

    policy action(:verify) do
      authorize_if actor_present()
    end

    policy action(:details) do
      authorize_if expr(roles.type in [:owner] and roles.user.id == ^actor(:id))
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true, allow_nil?: false

    attribute :handle, :string,
      public?: true,
      allow_nil?: false,
      constraints: [match: ~r"^[a-z0-9](-?[a-z0-9])*$", min_length: 3]

    attribute :logo, :string, public?: true

    attribute :paystack_subaccount_code, :string, public?: true

    attribute :verified_at, :utc_datetime, public?: true
    attribute :suspended_at, :utc_datetime, public?: true

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :owner, User, allow_nil?: false

    has_many :roles, Role, public?: true

    has_many :events, Event, domain: Storefront

    has_many :upcoming_events, Event do
      domain Storefront
      filter expr(state == :published)
    end

    has_many :orders, Order do
      domain Storefront
      no_attributes? true
      filter expr(event.id == parent(events.id))
    end
  end

  calculations do
    calculate :payment_method_ready?, :boolean, expr(not is_nil(paystack_subaccount_code))

    calculate :paystack_subaccount, :map, fn records, _ ->
      Enum.map(records, fn record ->
        PaystackApi.fetch_subaccount(record.paystack_subaccount_code, :cache)
        |> case do
          {:ok, subaccount} ->
            %{
              business_name: subaccount.business_name,
              account_number: subaccount.account_number,
              settlement_bank: subaccount.settlement_bank
            }

          _ ->
            nil
        end
      end)
    end

    calculate :paystack_business_name, :string, fn records, _ ->
      Enum.map(records, fn record ->
        record = Ash.load!(record, [:paystack_subaccount])

        case record.paystack_subaccount do
          nil -> nil
          subaccount -> subaccount.business_name
        end
      end)
    end

    calculate :paystack_account_number, :string, fn records, _ ->
      Enum.map(records, fn record ->
        record = Ash.load!(record, [:paystack_subaccount])

        case record.paystack_subaccount do
          nil -> nil
          subaccount -> subaccount.account_number
        end
      end)
    end

    calculate :paystack_settlement_bank, :string, fn records, _ ->
      Enum.map(records, fn record ->
        record = Ash.load!(record, [:paystack_subaccount])

        case record.paystack_subaccount do
          nil -> nil
          subaccount -> subaccount.settlement_bank
        end
      end)
    end
  end

  aggregates do
    count :total_events, :events
  end

  identities do
    identity :handle, [:handle]
  end
end
