defmodule Gits.Repo.Migrations.FixUniqueKeyToInvite do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    drop_if_exists unique_index(:ticket_invites, [:receipient_email, :ticket_id],
                     name: "ticket_invites_customer_ticket_invite_index"
                   )

    create unique_index(:ticket_invites, [:customer_id, :ticket_id],
             name: "ticket_invites_customer_ticket_invite_index"
           )

    create unique_index(:ticket_invites, [:receipient_email, :ticket_id],
             name: "ticket_invites_email_ticket_invite_index"
           )
  end

  def down do
    drop_if_exists unique_index(:ticket_invites, [:receipient_email, :ticket_id],
                     name: "ticket_invites_email_ticket_invite_index"
                   )

    drop_if_exists unique_index(:ticket_invites, [:customer_id, :ticket_id],
                     name: "ticket_invites_customer_ticket_invite_index"
                   )

    create unique_index(:ticket_invites, [:receipient_email, :ticket_id],
             name: "ticket_invites_customer_ticket_invite_index"
           )
  end
end
