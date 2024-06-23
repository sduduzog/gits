defmodule Gits.Storefront.Changes.EvaluatePaystackTransaction do
  alias Gits.PaystackApi
  use Ash.Resource.Change

  def change(changeset, _opts, %{actor: actor} = _context) do
    PaystackApi.verify_transaction(changeset.data.paystack_reference)
    |> case do
      {:ok, %{status: :success}} ->
        instances =
          changeset.data
          |> Ash.load!(:instances, actor: actor)
          |> Map.get(:instances)

        changeset
        |> AshStateMachine.transition_state(:settled_for_payment)
        |> Ash.Changeset.manage_relationship(
          :instances,
          Enum.map(instances, & &1.id),
          on_match: {:update, :prepare_for_use}
        )

      {:ok, %{status: :declined}} ->
        changeset

      {:ok, %{status: :ongoing}} ->
        changeset

      {:ok, %{status: :abandoned}} ->
        changeset
    end
  end
end
