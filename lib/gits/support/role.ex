defmodule Gits.Support.Role do
  use Ash.Resource, data_layer: AshPostgres.DataLayer, domain: Gits.Support

  postgres do
    table "support_roles"
    repo Gits.Repo
  end

  attributes do
    uuid_primary_key :id

    attribute :support, :boolean, default: false, allow_nil?: false, public?: true
    attribute :jobs, :boolean, default: false, allow_nil?: false, public?: true
    attribute :users, :boolean, default: false, allow_nil?: false, public?: true
    attribute :accounts, :boolean, default: false, allow_nil?: false, public?: true
    attribute :events, :boolean, default: false, allow_nil?: false, public?: true
    attribute :tickets, :boolean, default: false, allow_nil?: false, public?: true
    attribute :ticket_instances, :boolean, default: false, allow_nil?: false, public?: true
    attribute :baskets, :boolean, default: false, allow_nil?: false, public?: true
  end

  relationships do
    belongs_to :user, Gits.Auth.User do
      domain Gits.Auth
    end
  end

  identities do
    identity :user_role, [:id, :user_id]
  end
end
