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
    has_many :baskets, Gits.Storefront.Basket
  end

  aggregates do
    min :minimum_ticket_price, :tickets, :price
    max :maximum_ticket_price, :tickets, :price
    sum :customer_reserved_instance_total, :tickets, :customer_reserved_instance_total
  end

  calculations do
    calculate :masked_id, :string, Gits.Storefront.Calculations.MaskId
    calculate :address, :map, Gits.Storefront.Event.Calculations.Address

    calculate :ticket_price_varies,
              :boolean,
              expr(maximum_ticket_price - minimum_ticket_price > 0)
  end

  actions do
    default_accept :*
    defaults [:read, :destroy, update: :*]

    read :masked do
      argument :id, :string

      prepare before_action(fn query, _ ->
                argument = Ash.Query.get_argument(query, :id)

                case argument do
                  nil ->
                    query

                  input ->
                    id =
                      Sqids.new!()
                      |> Sqids.decode!(input)
                      |> hd()

                    query |> Ash.Query.filter(id: id)
                end
              end)

      prepare build(load: [:masked_id])
    end

    create :create do
      primary? true
      accept :*

      argument :account, :map
      change manage_relationship(:account, type: :append)
    end

    update :prepare_basket do
      require_atomic? false
      change ensure_selected([:tickets, :customer_reserved_instance_total])
      manual Gits.Storefront.Actions.PrepareBasket
    end

    update :update_address do
      accept :address_place_id
    end
  end

  policies do
    bypass action(:read) do
      forbid_unless expr(account.members.user.id == ^actor(:id))
      authorize_if expr(account.members.role in [:owner])
    end

    bypass action(:masked) do
      authorize_if expr(visibility in [:protected, :public] and not is_nil(^arg(:id)))
    end

    policy action([:masked, :read]) do
      forbid_unless expr(visibility == :public)
      authorize_if always()
    end

    policy action(:update_address) do
      authorize_if always()
    end

    policy action(:prepare_basket) do
      authorize_if actor_present()
    end

    policy action(:create) do
      authorize_if always()
    end

    policy action(:update) do
      authorize_if Gits.Checks.CanUpdate
    end

    policy action(:destroy) do
      authorize_if Gits.Checks.CanDestroy
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
