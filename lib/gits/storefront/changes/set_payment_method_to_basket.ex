defmodule Gits.Storefront.Changes.SetPaymentMethodToBasket do
  use Ash.Resource.Change

  def change(changeset, _opts, %{actor: _actor}) do
    changeset
    |> Ash.Changeset.before_action(fn changeset ->
      basket = changeset.data |> Ash.load!(:event)

      event =
        basket.event
        |> IO.inspect()

      changeset |> Ash.Changeset.change_attribute(:payment_method, event.payment_method)
    end)
  end
end
