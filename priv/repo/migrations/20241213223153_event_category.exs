defmodule Gits.Repo.Migrations.EventCategory do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:events) do
      add :category, :text, null: false, default: "other"
    end
  end

  def down do
    alter table(:events) do
      remove :category
    end
  end
end
