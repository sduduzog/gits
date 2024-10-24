defmodule Gits.Repo.Migrations.AssociateBasketToEvent do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:baskets) do
      add :event_id,
          references(:events,
            column: :id,
            name: "baskets_event_id_fkey",
            type: :bigint,
            prefix: "public"
          )
    end
  end

  def down do
    drop constraint(:baskets, "baskets_event_id_fkey")

    alter table(:baskets) do
      remove :event_id
    end
  end
end
