defmodule Gits.Storefront.Event do
  require Ash.Resource.Preparation.Builtins
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
    attribute :ends_at, :naive_datetime, allow_nil?: false, public?: true
    attribute :published_at, :datetime, public?: true

    attribute :visibility, :atom do
      allow_nil? false
      public? true
      constraints one_of: [:private, :protected, :public]
      default :private
    end

    attribute :payment_method, :atom do
      public? true
      constraints one_of: [:none, :paystack, :payfast]
    end

    create_timestamp :created_at, public?: true
    update_timestamp :updated_at, public?: true
  end

  relationships do
    belongs_to :account, Gits.Dashboard.Account do
      domain Gits.Dashboard
    end

    belongs_to :address, Gits.Admissions.Address do
      domain Gits.Admissions
    end

    has_many :tickets, Gits.Storefront.Ticket
    has_many :baskets, Gits.Storefront.Basket
    has_one :keypair, Gits.Storefront.Keypair
  end

  aggregates do
    min :minimum_ticket_price, :tickets, :price
    max :maximum_ticket_price, :tickets, :price
  end

  calculations do
    calculate :masked_id, :string, Gits.Storefront.Calculations.MaskId
    calculate :resolved_payment_method, :atom, expr(payment_method or account.payment_method)

    calculate :ticket_price_varies,
              :boolean,
              expr(maximum_ticket_price - minimum_ticket_price > 0)

    calculate :customer_has_tickets, :boolean, expr(customer_secured_instance_count > 0)
  end

  actions do
    defaults [:destroy, update: :*]

    read :read do
      primary? true

      argument :id, :integer
      argument :masked_id, :string

      prepare before_action(fn query, _ ->
                id = query |> Ash.Query.get_argument(:id)

                query =
                  if is_nil(id) do
                    query
                  else
                    query |> Ash.Query.filter(id: id)
                  end

                masked_id =
                  query
                  |> Ash.Query.get_argument(:masked_id)

                query =
                  if is_nil(masked_id) do
                    query
                  else
                    id =
                      Sqids.new!()
                      |> Sqids.decode!(masked_id)
                      |> hd()

                    query |> Ash.Query.filter(id: id)
                  end

                query
              end)

      prepare build(sort: [id: :desc])
    end

    update :publish do
      require_atomic? false

      change set_attribute(:published_at, &DateTime.utc_now/0)

      change fn changeset, %{actor: actor} ->
        changeset
        |> Ash.Changeset.before_action(fn changeset ->
          changeset
          |> Ash.Changeset.manage_relationship(
            :keypair,
            %{},
            type: :create
          )
        end)
      end
    end

    read :read_dashboard_events do
      argument :account_id, :uuid, allow_nil?: false
      filter expr(account.id == ^arg(:account_id))
      prepare build(sort: [id: :desc])
    end

    read :for_dashboard_event_details do
      argument :id, :integer, allow_nil?: false
      filter expr(id == ^arg(:id))
      prepare build(load: [:tickets])
    end

    read :for_feature do
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

      validate Gits.Storefront.Validations.EventDates

      argument :account, :map
      change manage_relationship(:account, type: :append)
    end
  end

  policies do
    policy action(:read) do
      authorize_if always()
    end

    policy action(:create) do
      authorize_if actor_present()
    end

    policy action(:publish) do
      forbid_if expr(is_nil(starts_at))
      forbid_if expr(is_nil(ends_at))
      forbid_if expr(starts_at > ends_at)
      authorize_if actor_present()
    end

    policy action(:for_dashboard_event_details) do
      authorize_if expr(
                     account.members.user.id == ^actor(:id) and
                       account.members.role in [:owner, :admin]
                   )
    end

    policy action(:for_dashboard_event_details) do
      authorize_if actor_present()
    end

    policy action(:for_dashboard_event_list) do
      authorize_if expr(
                     account.members.user.id == ^actor(:id) and
                       account.members.role in [:owner, :admin]
                   )
    end

    policy action(:for_dashboard_event_list) do
      authorize_if actor_present()
    end

    bypass action([:masked, :for_feature]) do
      authorize_if expr(visibility in [:protected, :public] and not is_nil(^arg(:id)))
    end

    policy action([:masked, :for_feature]) do
      forbid_unless expr(visibility == :public)
      authorize_if always()
    end

    policy action(:update_address) do
      authorize_if always()
    end

    policy [action(:update), changing_attributes(payment_method: [to: :paystack])] do
      authorize_if expr(account.paystack_ready)
    end

    policy action(:update) do
      authorize_if actor_present()
    end

    policy action(:destroy) do
      authorize_if actor_present()
    end
  end

  postgres do
    table "events"
    repo Gits.Repo
  end
end
