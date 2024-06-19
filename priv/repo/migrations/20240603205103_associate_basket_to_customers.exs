defmodule Gits.Repo.Migrations.AssociateBasketToCustomers do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:baskets) do
      add :customer_id,
          references(:customers,
            column: :id,
            name: "baskets_customer_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end
  end

  def down do
    drop constraint(:baskets, "baskets_customer_id_fkey")

    alter table(:baskets) do
      remove :customer_id
    end
  end
end