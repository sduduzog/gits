defmodule Gits.Workers.Basket do
  use Oban.Worker

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}} = job) do
    case Ash.get(Gits.Storefront.Basket, id, actor: job) do
      {:ok, basket} ->
        basket
        |> Ash.Changeset.for_update(:cancel, %{}, actor: job)
        |> Ash.update()

        :ok

      errors ->
        IO.inspect(errors)
        {:error, :the_thing_failed}
    end
  end
end
