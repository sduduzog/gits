defmodule Gits.Storefront.Event do
  alias Gits.Storefront.{Order, PayoutAccount, TicketType}
  alias Gits.Hosting.{Host, PayoutAccount}

  use Ash.Resource,
    domain: Gits.Storefront,
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
      accept [:name, :starts_at, :ends_at, :visibility]

      argument :host, :map
      change manage_relationship(:host, type: :append)
      change set_attribute(:public_id, &Nanoid.generate/0)
    end

    update :details do
      accept :*
    end

    update :publish do
      change atomic_update(:published_at, expr(fragment("now()")))
    end

    update :add_ticket_type do
      require_atomic? false
      argument :type, :map, allow_nil?: false
      change manage_relationship(:type, :ticket_types, type: :create)
    end

    update :edit_ticket_type do
      require_atomic? false
      argument :type, :map, allow_nil?: false
      change manage_relationship(:type, :ticket_types, on_match: :update)
    end

    update :archive_ticket_type do
      require_atomic? false
      argument :type, :map, allow_nil?: false
      change manage_relationship(:type, :ticket_types, on_match: :destroy)
    end

    update :create_order do
      require_atomic? false

      argument :order, :map, allow_nil?: false
      change manage_relationship(:order, :orders, type: :create)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :public_id, :string,
      allow_nil?: false,
      writable?: false,
      public?: true,
      default: &Nanoid.generate/0

    attribute :name, :string, public?: true, allow_nil?: false

    attribute :starts_at, :naive_datetime, public?: true, allow_nil?: false
    attribute :ends_at, :naive_datetime, public?: true, allow_nil?: false

    # attribute :description, :string, public?: true
    attribute :visibility, :atom, public?: true, constraints: [one_of: [:private, :public]]

    # attribute :payout_schedule, :atom, constraints: [one_of: [:auto, :manual]]
    attribute :published_at, :utc_datetime, public?: true

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :host, Host do
      allow_nil? false
    end

    belongs_to :payout_account, PayoutAccount

    has_many :ticket_types, TicketType
    has_many :orders, Order
  end

  calculations do
    calculate :published?, :boolean, expr(not is_nil(published_at))
  end
end
