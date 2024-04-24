defmodule Gits.Storefront.Actions.PrepareBasket do
  alias Gits.Storefront.Basket
  alias Gits.Storefront.Customer
  alias Gits.Storefront.Event
  use Ash.Resource.ManualUpdate

  def update(changeset, _opts, %{actor: %Customer{}}) do
    case changeset.data do
      %Event{} = event ->
        Ash.Changeset.for_create(Basket, :create, %{event: event})
        |> Ash.create()
        |> IO.inspect()

        {:ok, event}

      _ ->
        {:error, nil}
    end
  end
end
