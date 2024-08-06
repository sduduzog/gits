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

    has_many :invites, Gits.Dashboard.Invite

    has_many :events, Gits.Storefront.Event do
      domain Gits.Storefront
    end
  end

  calculations do
    calculate :paystack_subaccount, :map, Gits.Dashboard.Calculations.PaystackSubaccount
    calculate :paystack_ready, :boolean, expr(not is_nil(paystack_subaccount_code))
    calculate :payfast_ready, :boolean, expr(false)
    calculate :payments_ready, :boolean, expr(paystack_ready)
    calculate :no_payment_method, :boolean, expr(payments_ready == false)
    calculate :first_event_created, :boolean, expr(count(events) > 0)
    calculate :no_event_yet, :boolean, expr(count(events) == 0)
    calculate :no_invites_yet, :boolean, expr(count(invites) == 0)
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
    policy always() do
      authorize_if always()
    end
  end

  postgres do
    table "accounts"
    repo Gits.Repo
  end
end
