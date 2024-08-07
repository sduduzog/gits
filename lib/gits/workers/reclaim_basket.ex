defmodule Gits.Workers.ReclaimBasket do
  require Ash.Query
  alias Gits.Storefront.Basket
  use Oban.Worker

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}} = job) do
    Basket
    |> Ash.Query.for_read(:for_reclaim, %{id: id})
    |> Ash.read_one(actor: job)
    |> case do
      {:ok, basket} ->
        basket
        |> Ash.Changeset.for_update(:reclaim)
        |> Ash.update(actor: job)
        |> case do
          {:ok, _} ->
            :ok

          {:error, error} ->
            {:error, error}
        end

      {:error, error} ->
        {:error, error}
    end
  end
end
