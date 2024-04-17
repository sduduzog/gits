defmodule Gits.Storefront.Event do
  require Ash.Query
  require Ash.Resource.Preparation.Builtins

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource],
    authorizers: [Ash.Policy.Authorizer],
    domain: Gits.Storefront

  attributes do
    integer_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :description, :string, allow_nil?: false, public?: true
    attribute :starts_at, :naive_datetime, allow_nil?: false, public?: true
    attribute :address_place_id, :string, allow_nil?: true

    attribute :visibility, :atom do
      allow_nil? false
      public? true
      constraints one_of: [:private, :protected, :public]
      default :private
    end

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :account, Gits.Dashboard.Account do
      domain Gits.Dashboard
    end

    has_many :tickets, Gits.Storefront.Ticket
  end

  aggregates do
    min :minimum_ticket_price, :tickets, :price
  end

  calculations do
    calculate :masked_id, :string, Gits.Storefront.Calculations.MaskId
    calculate :address, :map, Gits.Storefront.Event.Calculations.Address
  end

  actions do
    default_accept :*
    defaults [:read, :destroy, update: :*]

    read :masked do
      argument :id, :string

      prepare before_action(fn query, _ ->
                id =
                  Sqids.new!()
                  |> Sqids.decode!(Ash.Query.get_argument(query, :id))
                  |> hd()

                query |> Ash.Query.filter(id: id)
              end)

      prepare build(load: [:masked_id])
    end

    create :create do
      accept :*

      argument :account, :map do
        allow_nil? false
      end

      change manage_relationship(:account, type: :create)
    end

    update :update_address do
      accept :address_place_id
    end
  end

  policies do
    policy action(:read) do
      forbid_if expr(visibility == :private)
      authorize_if always()
    end

    policy action(:masked) do
      authorize_if expr(visibility in [:protected, :public])
    end

    policy action(:create) do
      forbid_if always()
    end
  end

  postgres do
    table "events"
    repo Gits.Repo
  end
end

defmodule Gits.Storefront.Event.Calculations.Address do
  use Ash.Resource.Calculation

  def load(_, _, _) do
    [:address_place_id]
  end

  def calculate(records, _opts, _context) do
    Enum.map(records, fn record ->
      Gits.Cache.get_address(record.address_place_id)
    end)
  end
end
