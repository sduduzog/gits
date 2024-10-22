defmodule Gits.Hosts.Host do
  alias Gits.Hosts.Role
  alias Gits.Accounts
  alias Gits.Accounts.User

  use Ash.Resource,
    domain: Gits.Hosts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource]

  postgres do
    repo Gits.Repo
    table "hosts"
  end

  actions do
    defaults [:read, :destroy, update: :*]

    create :create do
      primary? true
      accept [:name, :logo]

      argument :owner, :map do
        allow_nil? false
      end

      change manage_relationship(:owner, type: :append)
      change set_attribute(:handle, &Nanoid.generate/0)
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

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :owner, User do
      domain Accounts
      allow_nil? false
    end

    has_many :roles, Role
  end
end
