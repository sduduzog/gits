defmodule Gits.Storefront.Event do
  require Ash.Resource.Preparation.Builtins
  require Ash.Query
  require Ash.Resource.Preparation.Builtins

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource],
    authorizers: [Ash.Policy.Authorizer],
    domain: Gits.Storefront

  alias Gits.Dashboard.Account

  attributes do
    integer_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :description, :string, allow_nil?: false, public?: true
    attribute :starts_at, :datetime, allow_nil?: false, public?: true
    attribute :ends_at, :datetime, allow_nil?: false, public?: true
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

    calculate :payment_method_required?,
              :boolean,
              expr(
                maximum_ticket_price > 0 and (is_nil(payment_method) or payment_method == :none)
              )

    calculate :host, :string, expr(account.name)

    calculate :local_starts_at,
              :naive_datetime,
              {Gits.Storefront.Calculations.LocalDatetime, attribute: :starts_at}

    calculate :local_ends_at,
              :naive_datetime,
              {Gits.Storefront.Calculations.LocalDatetime, attribute: :ends_at}
  end

  actions do
    defaults [:destroy]

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

      prepare build(load: [:local_starts_at, :local_ends_at])
      prepare build(sort: [id: :desc])
    end

    update :update do
      primary? true
      require_atomic? false
      accept [:name, :description, :visibility, :payment_method]

      argument :local_starts_at, :naive_datetime do
        allow_nil? false
      end

      argument :local_ends_at, :naive_datetime do
        allow_nil? false
      end

      change {Gits.Storefront.Changes.SetLocalTimezone,
              attribute: :starts_at, input: :local_starts_at}

      change {Gits.Storefront.Changes.SetLocalTimezone,
              attribute: :ends_at, input: :local_ends_at}
    end

    update :publish do
      require_atomic? false

      change set_attribute(:published_at, &DateTime.utc_now/0)
    end

    update :update_address do
      require_atomic? false

      argument :address, :map do
        allow_nil? false
      end

      change manage_relationship(:address,
               on_no_match: :create,
               on_match: :ignore,
               on_lookup: :relate
             )
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

      argument :local_starts_at, :naive_datetime, allow_nil?: false
      argument :local_ends_at, :naive_datetime, allow_nil?: false

      argument :account, :map
      change manage_relationship(:account, type: :append)

      change {Gits.Storefront.Changes.SetLocalTimezone, attribute: :starts_at}
      change {Gits.Storefront.Changes.SetLocalTimezone, attribute: :ends_at}

      change {Gits.Storefront.Changes.SetLocalTimezone,
              attribute: :starts_at, input: :local_starts_at}

      change {Gits.Storefront.Changes.SetLocalTimezone,
              attribute: :ends_at, input: :local_ends_at}
    end
  end

  policies do
    bypass [action(:read), accessing_from(Account, :events)] do
      authorize_if expr(account.members.user.id == ^actor(:id))
    end

    policy action(:read) do
      authorize_if expr(
                     account.members.user.id == ^actor(:id) and
                       account.members.role in [:owner, :admin]
                   )

      authorize_if expr(visibility in [:protected, :public])
    end

    policy action(:read) do
      authorize_if expr(
                     account.members.user.id == ^actor(:id) and
                       account.members.role in [:owner, :admin]
                   )

      authorize_if expr(not is_nil(published_at))
    end

    # policy action(:create) do
    #   authorize_if expr(
    #                  account.members.user.id == ^actor(:id) and
    #                    not is_nil(account.members.user.confirmed_at)
    #                )
    # end

    policy action(:create) do
      authorize_if actor_present()
    end

    policy action(:publish) do
      forbid_if expr(is_nil(starts_at))
      forbid_if expr(is_nil(ends_at))
      forbid_if expr(starts_at > ends_at)
      authorize_if actor_present()
    end

    policy action(:update_address) do
      authorize_if always()
    end

    policy action(:for_dashboard_event_details) do
      authorize_if expr(
                     account.members.user.id == ^actor(:id) and
                       account.members.role in [:owner, :admin]
                   )
    end

    policy [action(:update), changing_attributes(payment_method: [to: :paystack])] do
      authorize_if expr(account.paystack_ready)
    end

    policy [action(:update), changing_attributes(payment_method: [to: :none])] do
      authorize_if expr(
                     count(baskets,
                       query: [filter: expr(state in [:payment_started, :settled_for_payment])]
                     ) == 0
                   )
    end

    policy action(:update) do
      authorize_if expr(
                     account.members.user.id == ^actor(:id) and
                       account.members.role in [:owner, :admin]
                   )
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
