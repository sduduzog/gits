defmodule Gits.Repo.Migrations.MoveWebhookToStorefront do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:webhooks) do
      remove :host_id
    end
  end

  def down do
    alter table(:webhooks) do
      add :host_id,
          references(:hosts,
            column: :id,
            name: "webhooks_host_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end
  end
end
