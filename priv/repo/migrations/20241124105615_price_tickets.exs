defmodule Gits.Repo.Migrations.PriceTickets do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:ticket_types) do
      add :price, :decimal, null: false, default: "0"
    end
  end

  def down do
    alter table(:ticket_types) do
      remove :price
    end
  end
end
