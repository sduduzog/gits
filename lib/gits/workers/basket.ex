defmodule Gits.Workers.Basket do
  use Oban.Worker

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}} = job) do
    with {:ok, basket} <- Ash.get(Gits.Storefront.Basket, id, actor: job) do
      basket
      |> Ash.Changeset.for_update(:cancel, %{}, actor: job)
      |> Ash.update()

      :ok
    else
      _ ->
        {:error, :the_thing_failed}
    end
  end
end
