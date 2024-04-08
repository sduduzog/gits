defmodule Gits.Repo.Migrations.Initial do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:members) do
      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end

    alter table(:events) do
      add :description, :text, null: false
      add :starts_at, :naive_datetime, null: false

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end

    alter table(:accounts) do
      add :name, :text, null: false

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end
  end

  def down do
    alter table(:accounts) do
      remove :updated_at
      remove :created_at
      remove :name
    end

    alter table(:events) do
      remove :updated_at
      remove :created_at
      remove :starts_at
      remove :description
    end

    alter table(:members) do
      remove :updated_at
      remove :created_at
    end
  end
end
