defmodule Gits.Repo.Migrations.Initial do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:users, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :email, :citext, null: false
      add :display_name, :text
      add :archived_at, :utc_datetime_usec
    end

    create unique_index(:users, [:email], name: "users_unique_email_index")

    create table(:ticket_types, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :name, :text, null: false

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :event_id, :uuid
      add :archived_at, :utc_datetime_usec
    end

    create table(:payout_accounts, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :business_name, :text, null: false
      add :account_number, :text, null: false
      add :settlement_bank, :text, null: false
      add :percentage_charge, :decimal, null: false, default: "1.1"

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :host_id, :uuid
      add :archived_at, :utc_datetime_usec
    end

    create table(:interactions, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :type, :text

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end

    create table(:hosts, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
    end

    alter table(:payout_accounts) do
      modify :host_id,
             references(:hosts,
               column: :id,
               name: "payout_accounts_host_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    alter table(:hosts) do
      add :name, :text, null: false
      add :handle, :text, null: false
      add :logo, :text

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :owner_id,
          references(:users,
            column: :id,
            name: "hosts_owner_id_fkey",
            type: :uuid,
            prefix: "public"
          ),
          null: false

      add :archived_at, :utc_datetime_usec
    end

    create table(:host_roles, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :name, :text, null: false
      add :slug, :text, null: false
      add :type, :text

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :user_id,
          references(:users,
            column: :id,
            name: "host_roles_user_id_fkey",
            type: :uuid,
            prefix: "public"
          )

      add :host_id,
          references(:hosts,
            column: :id,
            name: "host_roles_host_id_fkey",
            type: :uuid,
            prefix: "public"
          )

      add :archived_at, :utc_datetime_usec
    end

    create table(:events, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
    end

    alter table(:ticket_types) do
      modify :event_id,
             references(:events,
               column: :id,
               name: "ticket_types_event_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    alter table(:events) do
      add :public_id, :text, null: false
      add :name, :text, null: false
      add :visibility, :text
      add :published_at, :utc_datetime

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :host_id,
          references(:hosts,
            column: :id,
            name: "events_host_id_fkey",
            type: :uuid,
            prefix: "public"
          ),
          null: false

      add :payout_account_id,
          references(:payout_accounts,
            column: :id,
            name: "events_payout_account_id_fkey",
            type: :uuid,
            prefix: "public"
          )

      add :archived_at, :utc_datetime_usec
    end

    create table(:account_tokens, primary_key: false) do
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
  end

  def down do
    drop table(:account_tokens)

    drop constraint(:events, "events_host_id_fkey")

    drop constraint(:events, "events_payout_account_id_fkey")

    alter table(:events) do
      remove :archived_at
      remove :payout_account_id
      remove :host_id
      remove :updated_at
      remove :created_at
      remove :published_at
      remove :visibility
      remove :name
      remove :public_id
    end

    drop constraint(:ticket_types, "ticket_types_event_id_fkey")

    alter table(:ticket_types) do
      modify :event_id, :uuid
    end

    drop table(:events)

    drop constraint(:host_roles, "host_roles_user_id_fkey")

    drop constraint(:host_roles, "host_roles_host_id_fkey")

    drop table(:host_roles)

    drop constraint(:hosts, "hosts_owner_id_fkey")

    alter table(:hosts) do
      remove :archived_at
      remove :owner_id
      remove :updated_at
      remove :created_at
      remove :logo
      remove :handle
      remove :name
    end

    drop constraint(:payout_accounts, "payout_accounts_host_id_fkey")

    alter table(:payout_accounts) do
      modify :host_id, :uuid
    end

    drop table(:hosts)

    drop table(:interactions)

    drop table(:payout_accounts)

    drop table(:ticket_types)

    drop_if_exists unique_index(:users, [:email], name: "users_unique_email_index")

    drop table(:users)
  end
end
