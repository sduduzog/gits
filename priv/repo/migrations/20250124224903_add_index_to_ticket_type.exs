defmodule Gits.Repo.Migrations.AddIndexToTicketType do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:ticket_types) do
      modify :event_id, :uuid, null: false
      add :order_index, :bigint, null: false, default: 0
    end
  end

  def down do
    alter table(:ticket_types) do
      remove :order_index
      modify :event_id, :uuid, null: true
    end
  end
end
