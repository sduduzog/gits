defmodule Gits.Repo.Migrations.AddResources do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:venues_versions, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :version_action_type, :text, null: false
      add :version_action_name, :text, null: false
      add :version_source_id, :uuid, null: false
      add :changes, :map

      add :version_inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :version_updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end

    create table(:venues, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
    end

    alter table(:venues_versions) do
      modify :version_source_id,
             references(:venues,
               column: :id,
               name: "venues_versions_version_source_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    alter table(:venues) do
      add :name, :text, null: false
      add :address, :text, null: false
      add :google_place_id, :text, null: false
      add :place_uri, :text
      add :surburb, :text
      add :city_or_town, :text
      add :province, :text, null: false
      add :postal_code, :text
      add :latitude, :decimal, null: false
      add :longitude, :decimal, null: false

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :host_id, :uuid, null: false
      add :archived_at, :utc_datetime_usec
    end

    create table(:users, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :email, :citext, null: false
      add :username, :text, null: false
      add :name, :text
      add :avatar, :text
      add :archived_at, :utc_datetime_usec
    end

    create unique_index(:users, [:email], name: "users_unique_email_index")

    create table(:user_identities, primary_key: false) do
      add :refresh_token, :text
      add :access_token_expires_at, :utc_datetime_usec
      add :access_token, :text
      add :uid, :text, null: false
      add :strategy, :text, null: false
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true

      add :user_id,
          references(:users,
            column: :id,
            name: "user_identities_user_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end

    create unique_index(:user_identities, [:strategy, :uid, :user_id],
             name: "user_identities_unique_on_strategy_and_uid_and_user_id_index"
           )

    create table(:tickets_versions, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :version_action_type, :text, null: false
      add :version_action_name, :text, null: false
      add :version_source_id, :uuid, null: false
      add :changes, :map

      add :version_inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :version_updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end

    create table(:tickets, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
    end

    alter table(:tickets_versions) do
      modify :version_source_id,
             references(:tickets,
               column: :id,
               name: "tickets_versions_version_source_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    alter table(:tickets) do
      add :public_id, :text, null: false
      add :admitted_at, :utc_datetime
      add :checked_in_at, :utc_datetime

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :attendee_id,
          references(:users,
            column: :id,
            name: "tickets_attendee_id_fkey",
            type: :uuid,
            prefix: "public"
          )

      add :order_id, :uuid, null: false
      add :ticket_type_id, :uuid, null: false
      add :archived_at, :utc_datetime_usec
      add :state, :text, null: false, default: "ready"
    end

    create table(:ticket_types_versions, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :version_action_type, :text, null: false
      add :version_action_name, :text, null: false
      add :version_source_id, :uuid, null: false
      add :changes, :map

      add :version_inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :version_updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end

    create table(:ticket_types, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
    end

    alter table(:ticket_types_versions) do
      modify :version_source_id,
             references(:ticket_types,
               column: :id,
               name: "ticket_types_versions_version_source_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    alter table(:ticket_types) do
      add :name, :text, null: false
      add :price, :decimal, null: false, default: "0"
      add :description, :text
      add :sale_starts_at, :naive_datetime, null: false
      add :sale_ends_at, :naive_datetime, null: false
      add :quantity, :bigint, null: false, default: 10
      add :limit_per_user, :bigint, null: false, default: 10
      add :color, :text
      add :check_in_enabled, :boolean, null: false, default: false

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :event_id, :uuid
      add :archived_at, :utc_datetime_usec
    end

    create table(:support_tickets, primary_key: false) do
      add :id, :bigserial, null: false, primary_key: true
      add :subject, :text, null: false
    end

    create table(:support_conversations, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
    end

    create table(:support_admins, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true

      add :user_id,
          references(:users,
            column: :id,
            name: "support_admins_user_id_fkey",
            type: :uuid,
            prefix: "public"
          )
    end

    create table(:orders_versions, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :version_action_type, :text, null: false
      add :version_action_name, :text, null: false
      add :version_source_id, :uuid, null: false
      add :changes, :map

      add :version_inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :version_updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end

    create table(:orders, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
    end

    alter table(:tickets) do
      modify :order_id,
             references(:orders,
               column: :id,
               name: "tickets_order_id_fkey",
               type: :uuid,
               prefix: "public"
             )

      modify :ticket_type_id,
             references(:ticket_types,
               column: :id,
               name: "tickets_ticket_type_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    alter table(:orders_versions) do
      modify :version_source_id,
             references(:orders,
               column: :id,
               name: "orders_versions_version_source_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    alter table(:orders) do
      add :number, :bigserial, null: false
      add :email, :citext
      add :total, :decimal
      add :cancelled_at, :utc_datetime_usec
      add :cancellation_reason, :text
      add :completed_at, :utc_datetime_usec
      add :requested_refund_secret, :binary
      add :requested_refund_at, :utc_datetime_usec
      add :paystack_reference, :text
      add :paystack_authorization_url, :text

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :event_id, :uuid, null: false
      add :archived_at, :utc_datetime_usec
      add :state, :text, null: false, default: "anonymous"
    end

    create table(:order_fees_splits, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :integration, :decimal
      add :paystack, :decimal
      add :subaccount, :decimal

      add :order_id,
          references(:orders,
            column: :id,
            name: "order_fees_splits_order_id_fkey",
            type: :uuid,
            prefix: "public"
          )

      add :archived_at, :utc_datetime_usec
    end

    create table(:interactions, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :viewer_id, :text
      add :type, :text

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :user_id,
          references(:users,
            column: :id,
            name: "interactions_user_id_fkey",
            type: :uuid,
            prefix: "public"
          )

      add :event_id, :uuid
    end

    create table(:hosts_versions, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :version_action_type, :text, null: false
      add :version_action_name, :text, null: false
      add :version_source_id, :uuid, null: false
      add :changes, :map

      add :version_inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :version_updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
    end

    create table(:hosts, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
    end

    alter table(:venues) do
      modify :host_id,
             references(:hosts,
               column: :id,
               name: "venues_host_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    create unique_index(:venues, [:google_place_id], name: "venues_place_id_index")

    alter table(:hosts_versions) do
      modify :version_source_id,
             references(:hosts,
               column: :id,
               name: "hosts_versions_version_source_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    alter table(:hosts) do
      add :name, :text, null: false
      add :handle, :text, null: false
      add :logo, :text
      add :paystack_subaccount_code, :text
      add :verified_at, :utc_datetime
      add :suspended_at, :utc_datetime

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
      add :state, :text, null: false, default: "pending"
    end

    create unique_index(:hosts, [:handle], name: "hosts_handle_index")

    create table(:host_roles, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :type, :text

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :user_id,
          references(:users,
            column: :id,
            name: "host_roles_user_id_fkey",
            type: :uuid,
            prefix: "public"
          ),
          null: false

      add :host_id,
          references(:hosts,
            column: :id,
            name: "host_roles_host_id_fkey",
            type: :uuid,
            prefix: "public"
          ),
          null: false

      add :archived_at, :utc_datetime_usec
    end

    create table(:events_versions, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :version_action_type, :text, null: false
      add :version_action_name, :text, null: false
      add :version_source_id, :uuid, null: false
      add :changes, :map

      add :version_inserted_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :version_updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")
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

    alter table(:orders) do
      modify :event_id,
             references(:events,
               column: :id,
               name: "orders_event_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    alter table(:interactions) do
      modify :event_id,
             references(:events,
               column: :id,
               name: "interactions_event_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    alter table(:events_versions) do
      modify :version_source_id,
             references(:events,
               column: :id,
               name: "events_versions_version_source_id_fkey",
               type: :uuid,
               prefix: "public"
             )
    end

    alter table(:events) do
      add :public_id, :text, null: false
      add :name, :text, null: false
      add :starts_at, :naive_datetime, null: false
      add :ends_at, :naive_datetime, null: false
      add :category, :text, null: false, default: "other"
      add :visibility, :text
      add :location_notes, :text
      add :location_is_private, :boolean, default: false
      add :summary, :text
      add :description, :text
      add :poster, :text
      add :published_at, :utc_datetime
      add :completed_at, :utc_datetime

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

      add :venue_id,
          references(:venues,
            column: :id,
            name: "events_venue_id_fkey",
            type: :uuid,
            prefix: "public"
          )

      add :archived_at, :utc_datetime_usec
      add :state, :text, null: false, default: "draft"
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

    drop constraint(:events, "events_venue_id_fkey")

    alter table(:events) do
      remove :state
      remove :archived_at
      remove :venue_id
      remove :host_id
      remove :updated_at
      remove :created_at
      remove :completed_at
      remove :published_at
      remove :poster
      remove :description
      remove :summary
      remove :location_is_private
      remove :location_notes
      remove :visibility
      remove :category
      remove :ends_at
      remove :starts_at
      remove :name
      remove :public_id
    end

    drop constraint(:events_versions, "events_versions_version_source_id_fkey")

    alter table(:events_versions) do
      modify :version_source_id, :uuid
    end

    drop constraint(:interactions, "interactions_event_id_fkey")

    alter table(:interactions) do
      modify :event_id, :uuid
    end

    drop constraint(:orders, "orders_event_id_fkey")

    alter table(:orders) do
      modify :event_id, :uuid
    end

    drop constraint(:ticket_types, "ticket_types_event_id_fkey")

    alter table(:ticket_types) do
      modify :event_id, :uuid
    end

    drop table(:events)

    drop table(:events_versions)

    drop constraint(:host_roles, "host_roles_user_id_fkey")

    drop constraint(:host_roles, "host_roles_host_id_fkey")

    drop table(:host_roles)

    drop_if_exists unique_index(:hosts, [:handle], name: "hosts_handle_index")

    drop constraint(:hosts, "hosts_owner_id_fkey")

    alter table(:hosts) do
      remove :state
      remove :archived_at
      remove :owner_id
      remove :updated_at
      remove :created_at
      remove :suspended_at
      remove :verified_at
      remove :paystack_subaccount_code
      remove :logo
      remove :handle
      remove :name
    end

    drop constraint(:hosts_versions, "hosts_versions_version_source_id_fkey")

    alter table(:hosts_versions) do
      modify :version_source_id, :uuid
    end

    drop_if_exists unique_index(:venues, [:google_place_id], name: "venues_place_id_index")

    drop constraint(:venues, "venues_host_id_fkey")

    alter table(:venues) do
      modify :host_id, :uuid
    end

    drop table(:hosts)

    drop table(:hosts_versions)

    drop constraint(:interactions, "interactions_user_id_fkey")

    drop table(:interactions)

    drop constraint(:order_fees_splits, "order_fees_splits_order_id_fkey")

    drop table(:order_fees_splits)

    alter table(:orders) do
      remove :state
      remove :archived_at
      remove :event_id
      remove :updated_at
      remove :created_at
      remove :paystack_authorization_url
      remove :paystack_reference
      remove :requested_refund_at
      remove :requested_refund_secret
      remove :completed_at
      remove :cancellation_reason
      remove :cancelled_at
      remove :total
      remove :email
      remove :number
    end

    drop constraint(:orders_versions, "orders_versions_version_source_id_fkey")

    alter table(:orders_versions) do
      modify :version_source_id, :uuid
    end

    drop constraint(:tickets, "tickets_order_id_fkey")

    drop constraint(:tickets, "tickets_ticket_type_id_fkey")

    alter table(:tickets) do
      modify :ticket_type_id, :uuid
      modify :order_id, :uuid
    end

    drop table(:orders)

    drop table(:orders_versions)

    drop constraint(:support_admins, "support_admins_user_id_fkey")

    drop table(:support_admins)

    drop table(:support_conversations)

    drop table(:support_tickets)

    alter table(:ticket_types) do
      remove :archived_at
      remove :event_id
      remove :updated_at
      remove :created_at
      remove :check_in_enabled
      remove :color
      remove :limit_per_user
      remove :quantity
      remove :sale_ends_at
      remove :sale_starts_at
      remove :description
      remove :price
      remove :name
    end

    drop constraint(:ticket_types_versions, "ticket_types_versions_version_source_id_fkey")

    alter table(:ticket_types_versions) do
      modify :version_source_id, :uuid
    end

    drop table(:ticket_types)

    drop table(:ticket_types_versions)

    drop constraint(:tickets, "tickets_attendee_id_fkey")

    alter table(:tickets) do
      remove :state
      remove :archived_at
      remove :ticket_type_id
      remove :order_id
      remove :attendee_id
      remove :updated_at
      remove :created_at
      remove :checked_in_at
      remove :admitted_at
      remove :public_id
    end

    drop constraint(:tickets_versions, "tickets_versions_version_source_id_fkey")

    alter table(:tickets_versions) do
      modify :version_source_id, :uuid
    end

    drop table(:tickets)

    drop table(:tickets_versions)

    drop_if_exists unique_index(:user_identities, [:strategy, :uid, :user_id],
                     name: "user_identities_unique_on_strategy_and_uid_and_user_id_index"
                   )

    drop constraint(:user_identities, "user_identities_user_id_fkey")

    drop table(:user_identities)

    drop_if_exists unique_index(:users, [:email], name: "users_unique_email_index")

    drop table(:users)

    alter table(:venues) do
      remove :archived_at
      remove :host_id
      remove :updated_at
      remove :created_at
      remove :longitude
      remove :latitude
      remove :postal_code
      remove :province
      remove :city_or_town
      remove :surburb
      remove :place_uri
      remove :google_place_id
      remove :address
      remove :name
    end

    drop constraint(:venues_versions, "venues_versions_version_source_id_fkey")

    alter table(:venues_versions) do
      modify :version_source_id, :uuid
    end

    drop table(:venues)

    drop table(:venues_versions)
  end
end
