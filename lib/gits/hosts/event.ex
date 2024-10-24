defmodule Gits.Hosts.Event do
  alias Gits.Hosts.{EventDetails, Host, PayoutAccount}

  use Ash.Resource,
    domain: Gits.Hosts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource]

  postgres do
    table "events"
    repo Gits.Repo
  end

  actions do
    defaults [:read, :destroy, update: :*]

    create :create do
      primary? true
      accept [:host_id]
      argument :details, :map, allow_nil?: false
      change manage_relationship(:details, type: :create)
      change set_attribute(:public_id, &Nanoid.generate/0)
    end

    update :details do
      require_atomic? false
      argument :details, :map, allow_nil?: false
      change manage_relationship(:details, type: :direct_control)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :public_id, :string, allow_nil?: false

    attribute :payout_schedule, :atom, constraints: [one_of: [:auto, :manual]]

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :host, Host do
      allow_nil? false
      public? true
    end

    belongs_to :payout_account, PayoutAccount

    has_one :details, EventDetails
  end

  calculations do
    calculate :ready_to_publish, :boolean, expr(false)
  end
end
