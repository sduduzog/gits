defmodule Gits.Storefront.Changes.SetLocalTimezone do
  use Ash.Resource.Change

  def init(opts) do
    if is_atom(opts[:attribute]) do
      {:ok, opts}
    else
      {:error, "attribute must be an atom"}
    end

    if is_atom(opts[:input]) do
      {:ok, opts}
    else
      {:error, "input must be an atom"}
    end
  end

  def change(changeset, opts, _context) do
    changeset
    |> Ash.Changeset.fetch_argument(opts[:input])
    |> case do
      {:ok, argument} ->
        time_zone = Application.get_env(:gits, :time_zone)

        {:ok, datetime} =
          argument
          |> DateTime.from_naive(time_zone)

        changeset |> Ash.Changeset.force_change_attribute(opts[:attribute], datetime)

      :error ->
        changeset
    end
  end
end
