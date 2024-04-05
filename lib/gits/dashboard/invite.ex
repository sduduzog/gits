defmodule Gits.Dashboard.Invite do
  require Ash.Resource.Change.Builtins

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource],
    authorizers: [Ash.Policy.Authorizer],
    domain: Gits.Dashboard

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string, allow_nil?: false

    attribute :role, :atom do
      constraints one_of: [:admin, :editor, :access_coordinator]
      allow_nil? false
    end

    attribute :status, :atom do
      constraints one_of: [:pending, :accepted, :declined]

      default :pending

      allow_nil? false
    end

    create_timestamp :created_at, public?: true

    update_timestamp :updated_at, public?: true
  end

  actions do
    defaults [:read, :update, :destroy]

    update :reject do
      change set_attribute(:status, :accepted)
    end
  end

  postgres do
    table "account_invites"
    repo Gits.Repo
  end
end
