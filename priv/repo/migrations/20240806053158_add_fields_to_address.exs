defmodule Gits.Repo.Migrations.AddFieldsToAddress do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:addresses) do
      add :city, :text, null: false
      add :province, :text, null: false
      add :display_name, :text, null: false
      add :short_format_address, :text, null: false
      add :google_maps_uri, :text, null: false
    end
  end

  def down do
    alter table(:addresses) do
      remove :google_maps_uri
      remove :short_format_address
      remove :display_name
      remove :province
      remove :city
    end
  end
end