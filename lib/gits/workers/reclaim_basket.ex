defmodule Gits.Workers.ReclaimBasket do
  require Ash.Query
  alias Gits.Storefront.Basket
  use Oban.Worker

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id, "state" => "open"}} = job) do
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

  def perform(%Oban.Job{args: %{"id" => id, "state" => "payment_started"}} = job) do
    Basket
    |> Ash.Query.for_read(:read)
    |> Ash.Query.filter(id: id)
    |> Ash.Query.filter(state in [:payment_started])
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
