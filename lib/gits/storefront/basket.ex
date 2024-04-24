defmodule Gits.Storefront.Basket do
  require Ash.Query
  require Ash.Resource.Change.Builtins
  require Ash.Resource.Change.Builtins
  require Ash.Resource.Change.Builtins
  alias Gits.Storefront.TicketInstance
  require Ash.Resource.Change.Builtins

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshStateMachine],
    domain: Gits.Storefront

  attributes do
    uuid_primary_key :id

    attribute :amount, :integer, allow_nil?: false, public?: true

    create_timestamp :created_at, public?: true

    update_timestamp :updated_at, public?: true
  end

  state_machine do
    initial_states [:open, :settled]
    default_initial_state :open

    transitions do
      transition :settle_free, from: :open, to: :settled
      transition :abandon, from: :open, to: :abandoned
    end
  end

  relationships do
    belongs_to :event, Gits.Storefront.Event do
      attribute_type :integer
    end

    has_many :instances, Gits.Storefront.TicketInstance
  end

  actions do
    defaults [:read, :update, :destroy]

    create :create do
      accept [:amount]
      primary? true

      argument :event, :map do
        allow_nil? false
      end

      argument :instances, {:array, :map} do
        allow_nil? false
      end

      change manage_relationship(:event, type: :append)

      change manage_relationship(:instances,
               on_lookup: {:relate_and_update, :add_to_basket},
               on_match: {:update, :add_to_basket}
             )
    end

    create :create_settled do
      accept [:amount]

      argument :event, :map do
        allow_nil? false
      end

      argument :instances, {:array, :map} do
        allow_nil? false
      end

      validate attribute_equals(:amount, 0)

      change set_attribute(:state, :settled)

      change manage_relationship(:event, type: :append)

      change manage_relationship(:instances,
               on_lookup: {:relate_and_update, :add_to_basket_ready},
               on_match: {:update, :add_to_basket_ready}
             )
    end

    update :settle_free do
      require_atomic? false

      validate attribute_equals(:amount, 0)
      change transition_state(:settled)

      change after_action(fn _, result, %{actor: actor} ->
               TicketInstance
               |> Ash.Query.for_read(:read, %{}, actor: actor)
               |> Ash.Query.filter(basket.id == ^result.id)
               |> Ash.read!()
               |> Enum.each(fn instance ->
                 instance
                 |> Ash.Changeset.for_update(:ready_to_scan, %{}, actor: actor)
                 |> Ash.update!()
               end)

               {:ok, result}
             end)
    end

    update :abandon do
      require_atomic? false

      change transition_state(:abandoned)

      change after_action(fn _, result, %{actor: actor} ->
               TicketInstance
               |> Ash.Query.for_read(:read, %{}, actor: actor)
               |> Ash.Query.filter(basket.id == ^result.id)
               |> Ash.read!()
               |> Enum.each(fn instance ->
                 instance
                 |> Ash.Changeset.for_update(:abandon, %{}, actor: actor)
                 |> Ash.update!()
               end)

               {:ok, result}
             end)
    end
  end

  policies do
    policy always() do
      authorize_if always()
    end
  end

  postgres do
    table "baskets"
    repo Gits.Repo
  end
end
