defmodule Gits.Storefront.Order.Changes.InitialState do
  use Ash.Resource.Change

  def change(changeset, _, _) do
    if Ash.Changeset.attribute_present?(changeset, :email) do
      changeset |> AshStateMachine.transition_state(:open)
    else
      changeset
    end
  end
end
