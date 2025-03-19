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

  code_interface do
    define :resend_email
    define :accept
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
      require_atomic? false
      # change atomic_update(:accepted_at, expr(fragment("now()")))
      # change transition_state(:accepted)

      change fn changeset, %{actor: actor} ->
        Ash.Changeset.before_action(changeset, fn changeset ->
          Ash.load(changeset.data, [:host], actor: actor)
          |> case do
            {:ok, invite} ->
              Ash.Changeset.manage_relationship(
                changeset,
                :role,
                %{host: invite.host, user: actor, type: invite.type},
                on_no_match: {:create, :assign}
              )
          end
        end)
      end
    end

    update :expire do
      change atomic_update(:expired_at, expr(fragment("now()")))
      change transition_state(:expired)
    end
  end

  policies do
    bypass [accessing_from(Host, :invites), action(:read)] do
      authorize_if expr(host.roles.type in [:owner] and host.roles.user.id == ^actor(:id))
    end

    policy action(:read) do
      authorize_if expr(email == ^actor(:email))
    end

    policy_group accessing_from(Host, :invites) do
      policy action(:create) do
        authorize_if always()
      end

      policy action(:destroy) do
        authorize_if expr(host.roles.type in [:owner] and host.roles.user.id == ^actor(:id))
      end
    end

    policy action(:resend_email) do
      authorize_if expr(host.roles.type in [:owner] and host.roles.user.id == ^actor(:id))
    end

    policy action(:accept) do
      authorize_if expr(email == ^actor(:email))
    end

    policy action(:destroy) do
      authorize_if expr(state == :sent)
    end
  end

  field_policies do
    field_policy :email do
      authorize_if expr(email == ^actor(:email))
      authorize_if expr(host.roles.type in [:owner] and host.roles.user.id == ^actor(:id))
    end

    field_policy :* do
      authorize_if always()
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

  calculations do
    calculate :host_name, :string, expr(host.name)
  end
end
