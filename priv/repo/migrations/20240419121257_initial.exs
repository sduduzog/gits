defmodule Gits.Repo.Migrations.Initial do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:users, primary_key: false) do
      add :confirmed_at, :utc_datetime_usec
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :email, :citext, null: false
      add :hashed_password, :text, null: false
      add :display_name, :text, null: false
    end

    create unique_index(:users, [:email], name: "users_unique_email_index")

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
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :name, :text, null: false
      add :price, :bigint, null: false

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :event_id, :bigint
    end

    create table(:ticket_instances, primary_key: false) do
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

      add :customer_id, :uuid
      add :basket_id, :uuid
      add :state, :text, null: false, default: "reserved"
    end

    create table(:members, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :role, :text, null: false, default: "owner"

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :account_id, :uuid
      add :user_id, :uuid
    end

    create table(:events, primary_key: false) do
      add :id, :bigserial, null: false, primary_key: true
    end

    alter table(:tickets) do
      modify :event_id,
             references(:events,
               column: :id,
               name: "tickets_event_id_fkey",
               type: :bigint,
               prefix: "public"
             )
    end

    alter table(:events) do
      add :name, :text, null: false
      add :description, :text, null: false
      add :starts_at, :naive_datetime, null: false
      add :address_place_id, :text
      add :visibility, :text, null: false, default: "private"

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :account_id, :uuid
    end

    create table(:customers, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
    end

    alter table(:ticket_instances) do
      modify :customer_id,
             references(:customers,
               column: :id,
               name: "ticket_instances_customer_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    alter table(:customers) do
      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :user_id,
          references(:users,
            column: :id,
            name: "customers_user_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end

    create unique_index(:customers, [:user_id], name: "customers_unique_user_id_index")

    create table(:baskets, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
    end

    alter table(:ticket_instances) do
      modify :basket_id,
             references(:baskets,
               column: :id,
               name: "ticket_instances_basket_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    alter table(:baskets) do
      add :amount, :bigint, null: false

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :state, :text, null: false, default: "open"
    end

    create table(:accounts, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
    end

    alter table(:members) do
      modify :account_id,
             references(:accounts,
               column: :id,
               name: "members_account_id_fkey",
               type: :uuid,
               prefix: "public"
             )

      modify :user_id,
             references(:users,
               column: :id,
               name: "members_user_id_fkey",
               type: :uuid,
               prefix: "public"
             )
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
      add :name, :text, null: false

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end

    create table(:account_invites, primary_key: false) do
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
    end
  end

  def down do
    drop table(:account_invites)

    alter table(:accounts) do
      remove :updated_at
      remove :created_at
      remove :name
    end

    drop constraint(:events, "events_account_id_fkey")

    alter table(:events) do
      modify :account_id, :uuid
    end

    drop constraint(:members, "members_account_id_fkey")

    drop constraint(:members, "members_user_id_fkey")

    alter table(:members) do
      modify :user_id, :uuid
      modify :account_id, :uuid
    end

    drop table(:accounts)

    alter table(:baskets) do
      remove :state
      remove :updated_at
      remove :created_at
      remove :amount
    end

    drop constraint(:ticket_instances, "ticket_instances_basket_id_fkey")

    alter table(:ticket_instances) do
      modify :basket_id, :uuid
    end

    drop table(:baskets)

    drop_if_exists unique_index(:customers, [:user_id], name: "customers_unique_user_id_index")

    drop constraint(:customers, "customers_user_id_fkey")

    alter table(:customers) do
      remove :user_id
      remove :updated_at
      remove :created_at
    end

    drop constraint(:ticket_instances, "ticket_instances_customer_id_fkey")

    alter table(:ticket_instances) do
      modify :customer_id, :uuid
    end

    drop table(:customers)

    alter table(:events) do
      remove :account_id
      remove :updated_at
      remove :created_at
      remove :visibility
      remove :address_place_id
      remove :starts_at
      remove :description
      remove :name
    end

    drop constraint(:tickets, "tickets_event_id_fkey")

    alter table(:tickets) do
      modify :event_id, :bigint
    end

    drop table(:events)

    drop table(:members)

    drop constraint(:ticket_instances, "ticket_instances_ticket_id_fkey")

    drop table(:ticket_instances)

    drop table(:tickets)

    drop table(:tokens)

    drop_if_exists unique_index(:users, [:email], name: "users_unique_email_index")

    drop table(:users)
  end
end
