defmodule Gits.Dashboard.Account do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    domain: Gits.Dashboard

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true
    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :members, Gits.Dashboard.Member

    has_many :events, Gits.Storefront.Event do
      domain Gits.Storefront
    end

    has_one :billing_settings, Gits.Dashboard.BillingSettings
  end

  calculations do
    calculate :billing_enabled?, :boolean, expr(count(billing_settings) > 0)
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

    create :create do
      primary? true
      accept :*

      argument :member, :map

      argument :event, :map

      change manage_relationship(:member, :members, type: :create)
      change manage_relationship(:event, :events, type: :create)
    end

    create :create_from_waitlist do
      accept :*

      argument :member, :map

      change manage_relationship(:member, :members, on_lookup: {:relate_and_update, :activate})
    end

    update :enable_billing do
      require_atomic? false
      argument :billing_settings, :map

      change manage_relationship(:billing_settings, type: :create)
    end
  end

  policies do
    policy action(:read) do
      authorize_if always()
    end

    policy action(:create_from_waitlist) do
      authorize_if Gits.Checks.ActorIsObanJob
    end

    policy action(:enable_billing) do
      authorize_if expr(members.user.id == ^actor(:id) and members.role in [:owner, :admin])
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
