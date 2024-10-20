defmodule Gits.Repo.Migrations.MakeInvitesUnique do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create unique_index(:account_invites, [:email, :account_id],
             name: "account_invites_unique_email_invite_index"
           )
  end

  def down do
    drop_if_exists unique_index(:account_invites, [:email, :account_id],
                     name: "account_invites_unique_email_invite_index"
                   )
  end
end
