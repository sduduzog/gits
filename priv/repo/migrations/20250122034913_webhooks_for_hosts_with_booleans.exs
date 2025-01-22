defmodule Gits.Repo.Migrations.WebhooksForHostsWithBooleans do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:webhooks) do
      remove :triggers
      add :order_completed, :boolean, default: false
      add :order_refunded, :boolean, default: false
    end
  end

  def down do
    alter table(:webhooks) do
      remove :order_refunded
      remove :order_completed
      add :triggers, {:array, :text}
    end
  end
end
