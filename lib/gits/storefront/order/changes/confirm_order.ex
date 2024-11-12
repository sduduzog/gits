defmodule Gits.Storefront.Order.Changes.ConfirmOrder do
  use Ash.Resource.Change

  def change(changeset, _, _) do
    changeset |> AshStateMachine.transition_state(:completed)
  end
end
