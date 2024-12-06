defmodule Gits.Repo.Migrations.AddColorToTicket do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:ticket_types) do
      add :color, :text
    end
  end

  def down do
    alter table(:ticket_types) do
      remove :color
    end
  end
end
