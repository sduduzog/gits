defmodule Gits.Dashboard.Account do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    domain: Gits.Dashboard

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :paystack_subaccount_code, :string, public?: true

    attribute :payment_method, :atom do
      public? true
      constraints one_of: [:paystack, :payfast]
    end

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :members, Gits.Dashboard.Member

    has_many :events, Gits.Storefront.Event do
      domain Gits.Storefront
    end
  end

  calculations do
    calculate :paystack_ready, :boolean, expr(not is_nil(paystack_subaccount_code))
    calculate :paystack_subaccount, :map, Gits.Dashboard.Calculations.PaystackSubaccount
    calculate :payfast_ready, :boolean, false
  end

  actions do
    default_accept :*
    defaults [:destroy, update: :*]

    read :read do
      primary? true

      prepare build(load: [:paystack_ready, :payfast_ready])
    end

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

      change Gits.Dashboard.Changes.UpdatePaystackSubaccount
    end
  end

  policies do
    policy action(:read) do
      authorize_if expr(members.user.id == ^actor(:id) and members.role in [:owner, :admin])
    end

    policy action(:update_paystack_account) do
      authorize_if expr(members.user.id == ^actor(:id) and members.role in [:owner, :admin])
      authorize_if actor_present()
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
