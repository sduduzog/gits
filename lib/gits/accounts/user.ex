defmodule Gits.Accounts.User do
  alias Gits.Secrets
  alias Gits.Accounts.{Host, Role, Token}
  alias Gits.Support.{Admin}
  alias Gits.Storefront.{Order}
  alias __MODULE__

  use Ash.Resource,
    domain: Gits.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: Ash.Policy.Authorizer,
    extensions: [AshAuthentication, AshArchival.Resource]

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

      google do
        client_id Secrets
        client_secret Secrets
        redirect_uri Secrets
      end
    end

    tokens do
      enabled? true
      token_resource Token

      signing_secret Secrets
    end
  end

  actions do
    default_accept :*
    defaults update: :*, create: :*

    read :read do
      primary? true
    end

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

    create :register_with_google do
      argument :user_info, :map, allow_nil?: false
      argument :oauth_tokens, :map, allow_nil?: false
      upsert? true
      upsert_identity :unique_email

      change AshAuthentication.GenerateTokenChange
      change AshAuthentication.Strategy.OAuth2.IdentityChange

      change fn changeset, _ ->
        user_info = Ash.Changeset.get_argument(changeset, :user_info)

        Ash.Changeset.change_attributes(changeset, Map.take(user_info, ["name", "email"]))
      end
    end
  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end

    policy action(:read) do
      authorize_if always()
    end

    policy action(:update) do
      authorize_if expr(id == ^actor(:id))
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string, allow_nil?: false, public?: true
    attribute :username, :string, allow_nil?: false, public?: true, default: &Nanoid.generate/0
    attribute :name, :string, public?: true
    attribute :avatar, :string, public?: true

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    has_one :admin, Admin
    has_many :roles, Role

    # has_many :hosts, Host do
    #   no_attributes? true
    # end

    many_to_many :hosts, Host do
      through Role
    end

    has_many :orders, Order do
      no_attributes? true
      domain Gits.Storefront
      filter expr(email == parent(email))
    end

    has_many :complete_orders, Order do
      no_attributes? true
      domain Gits.Storefront
      filter expr(email == parent(email) and state == :completed)
    end
  end

  aggregates do
    count :tickets_count, [:orders, :tickets] do
      join_filter :orders, expr(state == :completed)
      join_filter [:orders, :tickets], expr(order.state == :completed)
    end
  end

  identities do
    identity :unique_email, [:email] do
      eager_check_with Gits.Accounts
    end
  end
end
