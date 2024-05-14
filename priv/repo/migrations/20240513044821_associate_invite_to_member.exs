defmodule Gits.Repo.Migrations.AssociateInviteToMember do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:account_invites) do
      add :member_id,
          references(:members,
            column: :id,
            name: "account_invites_member_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end
  end

  def down do
    drop constraint(:account_invites, "account_invites_member_id_fkey")

    alter table(:account_invites) do
      remove :member_id
    end
  end
end