defmodule Gits.Accounts.Webhook do
  alias Gits.Accounts
  alias Gits.Accounts.{Host, WebhookEvent}
  alias Gits.Storefront
  alias Gits.Storefront.{Event}

  use Ash.Resource,
    domain: Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: Ash.Policy.Authorizer,
    extensions: [AshArchival.Resource, AshPaperTrail.Resource]

  postgres do
    table "webhooks"
    repo Gits.Repo
  end

  paper_trail do
    change_tracking_mode :changes_only
    store_action_name? true
    ignore_attributes [:created_at, :updated_at]
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true

      accept :*

      argument :event, :map

      change manage_relationship(:event, type: :append)
    end

    update :update do
      primary? true
      accept :*
    end
  end

  policies do
    policy action(:read) do
      authorize_if always()
    end

    policy action([:create, :update]) do
      authorize_if changing_attributes(order_completed: [to: true])
      authorize_if changing_attributes(order_refunded: [to: true])
    end

    policy action(:destroy) do
      authorize_if always()
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :url, :string, public?: true, allow_nil?: false
    attribute :order_completed, :boolean, public?: true, default: false
    attribute :order_refunded, :boolean, public?: true, default: false
    attribute :details, :string, public?: true

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :host, Host

    belongs_to :event, Event do
      domain Storefront
    end

    has_many :webhook_events, WebhookEvent
  end
end
