defmodule Gits.Repo.Migrations.InitialMigrations do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:users, primary_key: false) do
      add :confirmed_at, :utc_datetime_usec
      add :archived_at, :utc_datetime_usec
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :email, :citext, null: false
      add :hashed_password, :text, null: false
      add :display_name, :text, null: false
      add :avatar, :text
    end

    create unique_index(:users, [:email],
             where: "archived_at IS NULL",
             name: "users_unique_email_index"
           )

    create table(:tokens, primary_key: false) do
      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :extra_data, :map
      add :purpose, :text, null: false
      add :expires_at, :utc_datetime, null: false
      add :subject, :text, null: false
      add :jti, :text, null: false, primary_key: true
    end

    create table(:tickets, primary_key: false) do
      add :archived_at, :utc_datetime_usec
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :name, :text, null: false
      add :price, :bigint, null: false

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :event_id, :uuid
    end

    create table(:ticket_instances, primary_key: false) do
      add :archived_at, :utc_datetime_usec
      add :id, :bigserial, null: false, primary_key: true

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :ticket_id,
          references(:tickets,
            column: :id,
            name: "ticket_instances_ticket_id_fkey",
            type: :uuid,
            prefix: "public"
          )

      add :user_id,
          references(:users,
            column: :id,
            name: "ticket_instances_user_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end

    create table(:events, primary_key: false) do
      add :archived_at, :utc_datetime_usec
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
    end

    alter table(:tickets) do
      modify :event_id,
             references(:events,
               column: :id,
               name: "tickets_event_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    alter table(:events) do
      add :name, :text, null: false
      add :starts_at, :naive_datetime, null: false

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :account_id, :uuid
    end

    create table(:attendees, primary_key: false) do
      add :archived_at, :utc_datetime_usec
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :name, :text, null: false
      add :email, :citext, null: false

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :instance_id,
          references(:ticket_instances,
            column: :id,
            name: "attendees_instance_id_fkey",
            type: :bigint,
            prefix: "public"
          )

      add :event_id,
          references(:events,
            column: :id,
            name: "attendees_event_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end

    create unique_index(:attendees, [:email, :event_id],
             where: "archived_at IS NULL",
             name: "attendees_unique_per_event_index"
           )

    create table(:accounts, primary_key: false) do
      add :archived_at, :utc_datetime_usec
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
    end

    alter table(:events) do
      modify :account_id,
             references(:accounts,
               column: :id,
               name: "events_account_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    alter table(:accounts) do
      add :type, :text, null: false, default: "user"

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end

    create table(:account_roles, primary_key: false) do
      add :archived_at, :utc_datetime_usec
      add :type, :text, null: false, default: "owner"

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :user_id,
          references(:users,
            column: :id,
            name: "account_roles_user_id_fkey",
            type: :uuid,
            prefix: "public"
          ),
          primary_key: true,
          null: false

      add :account_id,
          references(:accounts,
            column: :id,
            name: "account_roles_account_id_fkey",
            type: :uuid,
            prefix: "public"
          ),
          primary_key: true,
          null: false
    end

    create table(:account_invites, primary_key: false) do
      add :archived_at, :utc_datetime_usec
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :email, :citext, null: false
      add :role, :text, null: false
      add :status, :text, null: false, default: "pending"

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :account_id,
          references(:accounts,
            column: :id,
            name: "account_invites_account_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end

    create unique_index(:account_invites, [:email, :account_id],
             where: "archived_at IS NULL",
             name: "account_invites_unique_email_invite_index"
           )
  end

  def down do
    drop_if_exists unique_index(:account_invites, [:email, :account_id],
                     name: "account_invites_unique_email_invite_index"
                   )

    drop constraint(:account_invites, "account_invites_account_id_fkey")

    drop table(:account_invites)

    drop constraint(:account_roles, "account_roles_user_id_fkey")

    drop constraint(:account_roles, "account_roles_account_id_fkey")

    drop table(:account_roles)

    alter table(:accounts) do
      remove :updated_at
      remove :created_at
      remove :type
    end

    drop constraint(:events, "events_account_id_fkey")

    alter table(:events) do
      modify :account_id, :uuid
    end

    drop table(:accounts)

    drop_if_exists unique_index(:attendees, [:email, :event_id],
                     name: "attendees_unique_per_event_index"
                   )

    drop constraint(:attendees, "attendees_instance_id_fkey")

    drop constraint(:attendees, "attendees_event_id_fkey")

    drop table(:attendees)

    alter table(:events) do
      remove :account_id
      remove :updated_at
      remove :created_at
      remove :starts_at
      remove :name
    end

    drop constraint(:tickets, "tickets_event_id_fkey")

    alter table(:tickets) do
      modify :event_id, :uuid
    end

    drop table(:events)

    drop constraint(:ticket_instances, "ticket_instances_ticket_id_fkey")

    drop constraint(:ticket_instances, "ticket_instances_user_id_fkey")

    drop table(:ticket_instances)

    drop table(:tickets)

    drop table(:tokens)

    drop_if_exists unique_index(:users, [:email], name: "users_unique_email_index")

    drop table(:users)
  end
end
