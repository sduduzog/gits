defmodule Gits.Accounts.WebhookEvent do
  alias Gits.Accounts
  alias Gits.Accounts.{Webhook}

  use Ash.Resource,
    domain: Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: Ash.Policy.Authorizer,
    extensions: [AshArchival.Resource]

  postgres do
    table "webhook_events"
    repo Gits.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :status, :atom do
      constraints one_of: [:success, :fail]
    end

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :webhook, Webhook
  end
end
