defmodule Gits.Auth.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication, AshArchival.Resource],
    authorizers: Ash.Policy.Authorizer,
    domain: Gits.Auth

  attributes do
    uuid_primary_key :id
    attribute :email, :ci_string, allow_nil?: false, public?: true
    attribute :hashed_password, :string, allow_nil?: false, sensitive?: true
    attribute :display_name, :string, allow_nil?: false, public?: true
  end

  relationships do
    has_one :member, Gits.Dashboard.Member do
      domain Gits.Dashboard
    end

    has_one :customer, Gits.Storefront.Customer
  end

  actions do
    default_accept :*
    defaults [:read]

    update :send_confirmation_email do
      accept []
    end
  end

  authentication do
    add_ons do
      confirmation :confirm do
        monitor_fields [:email]
        sender Gits.Auth.Senders.EmailConfirmation
      end
    end

    strategies do
      password :password do
        identity_field :email
        sign_in_tokens_enabled? true
        registration_enabled? true
        confirmation_required? false

        register_action_accept [:display_name]

        resettable do
          sender Gits.Auth.Senders.PasswordReset
        end
      end
    end

    tokens do
      enabled? true
      token_resource Gits.Auth.Token

      signing_secret Gits.Secrets
    end
  end

  postgres do
    table "users"
    repo Gits.Repo
  end

  identities do
    identity :unique_email, [:email] do
      eager_check_with Gits.Auth
    end
  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end

    policy always() do
      forbid_if always()
    end
  end
end
