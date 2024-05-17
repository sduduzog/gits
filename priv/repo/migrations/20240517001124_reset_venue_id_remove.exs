defmodule Gits.Repo.Migrations.ResetVenueIdRemove do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    rename table(:venues), :id, to: :place_id

    alter table(:venues) do
      modify :place_id, :text
    end

    alter table(:events) do
      # Attribute removal has been commented out to avoid data loss. See the migration generator documentation for more
      # If you uncomment this, be sure to also uncomment the corresponding attribute *addition* in the `down` migration
      remove :address_place_id
    end
  end

  def down do
    alter table(:events) do
      # This is the `down` migration of the statement:
      #
      #     remove :address_place_id
      #
      # 
      add :address_place_id, :text
    end

    alter table(:venues) do
      modify :id, :text
    end

    rename table(:venues), :place_id, to: :id
  end
end
