defmodule Gits.Dashboard.Account do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    domain: Gits.Dashboard

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :paystack_subbaccount_code, :string, public?: true
    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :members, Gits.Dashboard.Member

    has_many :events, Gits.Storefront.Event do
      domain Gits.Storefront
    end
  end

  actions do
    default_accept :*
    defaults [:read, :destroy, update: :*]

    read :by_id do
      argument :id, :uuid do
        allow_nil? false
      end

      filter expr(id == ^arg(:id))
    end

    read :read_for_dashboard do
      argument :id, :uuid do
        allow_nil? false
      end

      filter expr(id == ^arg(:id))
    end

    read :list_for_dashboard do
      argument :user_id, :uuid do
        allow_nil? false
      end

      filter expr(members.user.id == ^arg(:user_id))
    end

    create :create do
      primary? true

      change fn changeset, %{actor: actor} ->
        changeset
        |> Ash.Changeset.before_action(fn changeset ->
          changeset
          |> Ash.Changeset.manage_relationship(
            :members,
            [%{user: actor}],
            type: :create
          )
        end)
      end
    end

    create :create_from_waitlist do
      accept :*

      argument :member, :map

      change manage_relationship(:member, :members, on_lookup: {:relate_and_update, :activate})
    end

    update :update_paystack_account do
      require_atomic? false

      argument :business_name, :string, allow_nil?: false
      argument :account_number, :string, allow_nil?: false
      argument :settlement_bank, :string, allow_nil?: false

      change before_action(fn changeset, _ ->
               Gits.PaystackApi.create_subaccount(
                 Ash.Changeset.get_argument(changeset, :business_name),
                 Ash.Changeset.get_argument(changeset, :account_number),
                 Ash.Changeset.get_argument(changeset, :settlement_bank)
               )
               |> case do
                 {:ok, account} ->
                   Ash.Changeset.change_new_attribute(
                     changeset,
                     :paystack_subbaccount_code,
                     account.subaccount_code
                   )

                 _ ->
                   Ash.Changeset.add_error(changeset, field: :test, message: "test error message")
               end
             end)
    end
  end

  policies do
    policy action(:read) do
      authorize_if always()
    end

    policy action([:read_for_dashboard, :list_for_dashboard]) do
      authorize_if expr(members.user.id == ^actor(:id))
    end

    policy action(:create_from_waitlist) do
      authorize_if Gits.Checks.ActorIsObanJob
    end

    policy action([:by_id, :create, :enable_billing]) do
      authorize_if actor_present()
    end
  end

  postgres do
    table "accounts"
    repo Gits.Repo
  end
end
