defmodule Gits.Storefront.Validations.EventDates do
  use Ash.Resource.Validation

  def validate(changeset, _, _) do
    with %NaiveDateTime{} = starts_at <- Ash.Changeset.get_attribute(changeset, :starts_at),
         %NaiveDateTime{} = ends_at <- Ash.Changeset.get_attribute(changeset, :ends_at),
         {:ok, _} <-
           earliest_starts_at(starts_at) do
      starts_at
      |> NaiveDateTime.compare(ends_at)
      |> case do
        :lt ->
          :ok

        _ ->
          {:error, field: :ends_at, message: "must be greater"}
      end
    else
      {:error, reason} -> {:error, reason}
      nil -> :ok
    end
  end

  defp earliest_starts_at(starts_at) do
    NaiveDateTime.local_now()
    |> NaiveDateTime.compare(starts_at)
    |> case do
      :lt -> {:ok, starts_at}
      _ -> {:error, field: :starts_at, message: "should be ahead a bit"}
    end
  end
end
