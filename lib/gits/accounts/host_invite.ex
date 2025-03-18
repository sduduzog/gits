defmodule Gits.Accounts.HostInvite do
  alias Gits.Accounts
  alias Gits.Accounts.{Role, RoleType, Host}

  use Ash.Resource,
    domain: Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: Ash.Policy.Authorizer,
    extensions: [AshArchival.Resource, AshStateMachine, AshPaperTrail.Resource]

  postgres do
    repo Gits.Repo
    table "host_invites"
  end

  state_machine do
    initial_states [:sent]
    default_initial_state :sent

    transitions do
      transition :accept, from: :sent, to: :accepted
      transition :expire, from: :sent, to: :expired
    end
  end

  paper_trail do
    change_tracking_mode :changes_only
    store_action_name? true
    ignore_attributes [:created_at, :updated_at]
  end

  code_interface do
    define :resend_email
  end

  actions do
    defaults [:read, :destroy, update: :*]

    create :create do
      primary? true
      accept [:email, :type]

      change fn changeset, %{actor: actor} ->
        Ash.Changeset.after_action(changeset, fn changeset, result ->
          Ash.load(result, [:host], actor: actor)
          |> case do
            {:ok, invite} ->
              Gits.Mailer.deliver_host_invite(
                invite.email,
                invite.host.handle,
                invite.host.name,
                invite.id
              )

              {:ok, result}
          end
        end)
      end
    end

    update :resend_email do
      require_atomic? false

      change fn changeset, %{actor: actor} ->
        Ash.Changeset.after_action(changeset, fn changeset, result ->
          Ash.load(result, [:host], actor: actor)
          |> case do
            {:ok, invite} ->
              Gits.Mailer.deliver_host_invite(
                invite.email,
                invite.host.handle,
                invite.host.name,
                invite.id
              )

              {:ok, result}
          end
        end)
      end
    end

    update :accept do
      change atomic_update(:accepted_at, expr(fragment("now()")))
      change transition_state(:accepted)
    end

    update :expire do
      change atomic_update(:expired_at, expr(fragment("now()")))
      change transition_state(:expired)
    end
  end

  policies do
    policy action(:create) do
      authorize_if accessing_from(Host, :invites)
    end

    policy action(:read) do
      authorize_if accessing_from(Host, :invites)
    end

    policy action(:destroy) do
      authorize_if expr(state == :sent)
    end

    policy action(:destroy) do
      authorize_if expr(host.roles.type in [:owner] and host.roles.user.id == ^actor(:id))
    end

    policy action(:resend_email) do
      authorize_if expr(host.roles.type in [:owner] and host.roles.user.id == ^actor(:id))
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :email, :ci_string, allow_nil?: false, public?: true
    attribute :type, RoleType

    attribute :accepted_at, :utc_datetime, public?: true
    attribute :expired_at, :utc_datetime, public?: true

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :role, Role
    belongs_to :host, Host, allow_nil?: false
  end
end
