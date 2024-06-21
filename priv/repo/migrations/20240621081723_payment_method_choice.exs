defmodule Gits.Repo.Migrations.PaymentMethodChoice do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    drop_if_exists unique_index(:members, [:account_id, :user_id],
                     name: "members_account_member_index"
                   )

    create unique_index(:members, [:user_id, :account_id], name: "members_account_member_index")

    alter table(:events) do
      add :payment_method, :text
    end

    drop_if_exists unique_index(:attendees, [:event_id, :instance_id, :user_id],
                     name: "attendees_admission_identity_index"
                   )

    create unique_index(:attendees, [:user_id, :event_id, :instance_id],
             name: "attendees_admission_identity_index"
           )

    alter table(:accounts) do
      add :payment_method, :text
    end

    drop_if_exists unique_index(:account_invites, [:account_id, :email],
                     name: "account_invites_unique_email_invite_index"
                   )

    create unique_index(:account_invites, [:email, :account_id],
             name: "account_invites_unique_email_invite_index"
           )
  end

  def down do
    drop_if_exists unique_index(:account_invites, [:email, :account_id],
                     name: "account_invites_unique_email_invite_index"
                   )

    create unique_index(:account_invites, [:account_id, :email],
             name: "account_invites_unique_email_invite_index"
           )

    alter table(:accounts) do
      remove :payment_method
    end

    drop_if_exists unique_index(:attendees, [:user_id, :event_id, :instance_id],
                     name: "attendees_admission_identity_index"
                   )

    create unique_index(:attendees, [:event_id, :instance_id, :user_id],
             name: "attendees_admission_identity_index"
           )

    alter table(:events) do
      remove :payment_method
    end

    drop_if_exists unique_index(:members, [:user_id, :account_id],
                     name: "members_account_member_index"
                   )

    create unique_index(:members, [:account_id, :user_id], name: "members_account_member_index")
  end
end
