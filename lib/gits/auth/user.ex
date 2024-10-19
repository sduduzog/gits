defmodule Gits.Auth.User do
  alias Gits.Hosts
  alias Gits.Hosts.Role

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication, AshArchival.Resource],
    authorizers: Ash.Policy.Authorizer,
    domain: Gits.Auth

  postgres do
    table "users"
    repo Gits.Repo
  end

  authentication do
    strategies do
      magic_link do
        identity_field :email
        single_use_token? false
        sender Gits.Auth.Senders.SendMagicLink
      end
    end

    tokens do
      enabled? true
      token_resource Gits.Auth.Token

      signing_secret Gits.Secrets
    end
  end

  actions do
    default_accept :*
    defaults [:read]
  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end

    policy action(:read) do
      authorize_if accessing_from(Customer, :user)
      authorize_if actor_present()
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :email, :ci_string, allow_nil?: false, public?: true
    attribute :display_name, :string, allow_nil?: false, public?: true
  end

  relationships do
    has_many :roles, Role do
      domain Hosts
    end
  end

  identities do
    identity :unique_email, [:email] do
      eager_check_with Gits.Auth
    end
  end
end
