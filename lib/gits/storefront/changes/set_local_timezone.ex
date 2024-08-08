defmodule Gits.Storefront.Changes.SetLocalTimezone do
  use Ash.Resource.Change

  def init(opts) do
    if is_atom(opts[:attribute]) do
      {:ok, opts}
    else
      {:error, "attribute must be an atom"}
    end
  end

  def change(changeset, opts, _context) do
    changeset
    |> Ash.Changeset.fetch_change(opts[:attribute])
    |> case do
      {:ok, new_value} ->
        time_zone = Application.get_env(:gits, :time_zone)

        {:ok, datetime} =
          new_value
          |> DateTime.from_naive(time_zone)

        changeset |> Ash.Changeset.force_change_attribute(opts[:attribute], datetime)

      :error ->
        changeset
    end
  end
end
