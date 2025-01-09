defmodule Gits.Repo.Migrations.TrackOrderVersions do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:orders_versions, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :version_action_type, :text, null: false
      add :version_action_name, :text, null: false

      add :version_source_id,
          references(:orders,
            column: :id,
            name: "orders_versions_version_source_id_fkey",
            type: :uuid,
            prefix: "public"
          ),
          null: false

      add :changes, :map

      add :version_inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :version_updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end
  end

  def down do
    drop constraint(:orders_versions, "orders_versions_version_source_id_fkey")

    drop table(:orders_versions)
  end
end
