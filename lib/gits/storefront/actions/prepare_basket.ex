defmodule Gits.Storefront.Actions.PrepareBasket do
  require Ash.Query
  alias Gits.Storefront.TicketInstance
  alias Gits.Storefront.Basket
  alias Gits.Storefront.Customer
  alias Gits.Storefront.Event
  use Ash.Resource.ManualUpdate

  def update(changeset, _opts, %{actor: %Customer{} = customer}) do
    case changeset.data do
      %Event{} = event ->
        amount = event.customer_reserved_instance_total

        instances =
          event.tickets
          |> Ash.load!([instances: TicketInstance |> Ash.Query.filter(state == :reserved)],
            actor: customer
          )
          |> Enum.flat_map(fn ticket -> ticket.instances end)

        if amount == 0 do
          Ash.Changeset.for_create(
            Basket,
            :create_settled,
            %{amount: amount, event: event, instances: instances},
            actor: customer
          )
          |> Ash.create()
        end

        {:ok, event}

      _ ->
        {:error, nil}
    end
  end
end
