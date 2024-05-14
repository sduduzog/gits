defmodule Gits.Repo.Migrations.EnsureUniqueMember do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create unique_index(:members, [:user_id, :account_id], name: "members_account_member_index")
  end

  def down do
    drop_if_exists unique_index(:members, [:user_id, :account_id],
                     name: "members_account_member_index"
                   )
  end
end