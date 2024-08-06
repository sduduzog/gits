defmodule Gits.Repo.Migrations.PointToCorrectResource do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    drop constraint(:events, "events_address_id_fkey")

    alter table(:events) do
      modify :address_id,
             references(:addresses,
               column: :id,
               name: "events_address_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    execute("ALTER TABLE events alter CONSTRAINT events_address_id_fkey NOT DEFERRABLE")
  end

  def down do
    drop constraint(:events, "events_address_id_fkey")

    alter table(:events) do
      modify :address_id,
             references(:venues,
               column: :id,
               name: "events_address_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end
  end
end