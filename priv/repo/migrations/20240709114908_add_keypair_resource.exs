defmodule Gits.Repo.Migrations.AddKeypairResource do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:keypairs, primary_key: false) do
      add :private_key, :text, null: false
      add :public_key, :text, null: false

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :event_id,
          references(:events,
            column: :id,
            name: "keypairs_event_id_fkey",
            type: :bigint,
            prefix: "public"
          ),
          primary_key: true,
          null: false
    end
  end

  def down do
    drop constraint(:keypairs, "keypairs_event_id_fkey")

    drop table(:keypairs)
  end
end