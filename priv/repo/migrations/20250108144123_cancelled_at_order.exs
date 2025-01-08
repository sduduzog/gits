defmodule Gits.Repo.Migrations.CancelledAtOrder do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:orders) do
      add :cancelled_at, :utc_datetime_usec
    end
  end

  def down do
    alter table(:orders) do
      remove :cancelled_at
    end
  end
end
