defmodule Gits.Storefront.Changes.SetPaymentMethodToBasket do
  use Ash.Resource.Change

  def change(changeset, _opts, _context) do
    changeset
    |> Ash.Changeset.before_action(fn changeset ->
      basket = changeset.data

      changeset |> Ash.Changeset.change_attribute(:payment_method, basket.event.payment_method)
    end)
  end
end
