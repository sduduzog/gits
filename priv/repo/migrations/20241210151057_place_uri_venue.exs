defmodule Gits.Repo.Migrations.PlaceUriVenue do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:venues) do
      add :place_uri, :text
    end
  end

  def down do
    alter table(:venues) do
      remove :place_uri
    end
  end
end
