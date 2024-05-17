defmodule Gits.Repo.Migrations.ReaddIdToVenue do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    drop constraint("venues", "venues_pkey")

    alter table(:venues) do
      modify :place_id, :text, primary_key: false
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
    end
  end

  def down do
    drop constraint("venues", "venues_pkey")

    alter table(:venues) do
      remove :id
      modify :place_id, :text, primary_key: true
    end
  end
end
