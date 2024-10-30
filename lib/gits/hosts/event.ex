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

  code_interface do
    define :publish_event, action: :publish
    define :get_by_public_id_for_listing, args: [:public_id]
  end

  actions do
    defaults [:read, :destroy, update: :*]

    read :get_by_public_id_for_listing do
      get_by [:public_id]
      prepare build(load: [:name])
    end

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

    update :publish do
      change atomic_update(:published_at, expr(fragment("now()")))
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :public_id, :string, allow_nil?: false

    attribute :payout_schedule, :atom, constraints: [one_of: [:auto, :manual]]
    attribute :published_at, :utc_datetime, public?: true

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
    calculate :name, :string, expr(details.name)
    calculate :ready_to_publish, :boolean, expr(false)
    calculate :published?, :boolean, expr(not is_nil(published_at))
  end
end
