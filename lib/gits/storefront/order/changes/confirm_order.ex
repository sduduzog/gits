defmodule Gits.Storefront.Order.Changes.ConfirmOrder do
  require Decimal
  use Ash.Resource.Change

  def change(changeset, _, _) do
    if changeset.data.total |> Decimal.gt?(Decimal.new("0")) do
      changeset |> AshStateMachine.transition_state(:confirmed)
    else
      changeset |> AshStateMachine.transition_state(:completed)
    end
  end
end
