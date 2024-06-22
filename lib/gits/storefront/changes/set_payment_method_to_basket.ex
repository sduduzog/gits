defmodule Gits.Storefront.Changes.SetPaymentMethodToBasket do
  use Ash.Resource.Change

  def change(changeset, _opts, %{actor: _actor}) do
    changeset
    |> Ash.Changeset.before_action(fn changeset ->
      changeset |> IO.inspect()
    end)
  end
end
