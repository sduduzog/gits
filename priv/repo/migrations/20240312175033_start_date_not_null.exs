defmodule Gits.Repo.Migrations.StartDateNotNull do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:events) do
      modify :starts_at, :utc_datetime, null: false
    end
  end

  def down do
    alter table(:events) do
      modify :starts_at, :utc_datetime, null: true
    end
  end
end