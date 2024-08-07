defmodule Gits.Workers.ReclaimBasket do
  require Ash.Query
  alias Gits.Storefront.Basket
  use Oban.Worker

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}} = job) do
    Basket
    |> Ash.Query.for_read(:read)
    |> Ash.Query.filter(id: id)
    |> Ash.Query.filter(state in [:open])
    |> Ash.read_one(actor: job)
    |> case do
      {:ok, nil} ->
        :ok

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
