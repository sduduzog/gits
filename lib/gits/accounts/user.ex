defmodule Gits.Accounts.User do
  alias Gits.Hosting
  alias Gits.Hosting.Role
  alias Gits.Accounts.{Token}
  alias __MODULE__

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication, AshArchival.Resource],
    authorizers: Ash.Policy.Authorizer,
    domain: Gits.Accounts

  postgres do
    table "users"
    repo Gits.Repo
  end

  authentication do
    strategies do
      magic_link do
        identity_field :email
        registration_enabled? true
        single_use_token? false

        sender User.Senders.SendMagicLinkEmail
      end
    end

    tokens do
      enabled? true
      token_resource Token

      signing_secret Gits.Secrets
    end
  end

  actions do
    default_accept :*
    defaults [:read, create: :*]

    read :get_by_email do
      description "Looks up a user by their email"
      get? true

      argument :email, :ci_string do
        allow_nil? false
      end

      filter expr(email == ^arg(:email))
    end

    create :sign_in_with_magic_link do
      description "Sign in or register a user with magic link."

      argument :token, :string do
        description "The token from the magic link that was sent to the user"
        allow_nil? false
      end

      upsert? true
      upsert_identity :unique_email
      upsert_fields [:email]

      # Uses the information from the token to create or sign in the user
      change AshAuthentication.Strategy.MagicLink.SignInChange

      metadata :token, :string do
        allow_nil? false
      end
    end

    action :request_magic_link do
      argument :email, :ci_string do
        allow_nil? false
      end

      run AshAuthentication.Strategy.MagicLink.Request
    end
  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end

    policy action(:read) do
      authorize_if always()
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :email, :ci_string, allow_nil?: false, public?: true
    attribute :display_name, :string, public?: true
  end

  relationships do
    has_many :roles, Role do
      domain Hosting
    end
  end

  identities do
    identity :unique_email, [:email] do
      eager_check_with Gits.Accounts
    end
  end
end
