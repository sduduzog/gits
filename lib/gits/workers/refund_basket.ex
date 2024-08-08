defmodule Gits.Workers.RefundBasket do
  require Ash.Query
  alias Gits.Storefront.Basket
  use Oban.Worker

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}} = job) do
    Basket
    |> Ash.Query.for_read(:read)
    |> Ash.Query.filter(id: id)
    |> Ash.Query.filter(state in [:reclaimed, :cancelled])
    |> Ash.read_one!(actor: job, not_found_error?: true)

    :ok
  end
end
