defmodule Gits.Auth.User do
  alias Gits.Storefront.Customer

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

    create :register_with_email do
      accept [:display_name, :email]
    end

    update :send_confirmation_email do
      require_atomic? false
      accept []
    end
  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end

    policy action(:register_with_email) do
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
    has_one :member, Gits.Dashboard.Member do
      domain Gits.Dashboard
    end

    has_one :customer, Gits.Storefront.Customer
  end

  identities do
    identity :unique_email, [:email] do
      eager_check_with Gits.Auth
    end
  end
end

defimpl FunWithFlags.Actor, for: Gits.Auth.User do
  def id(%{id: id}) do
    "user:#{id}"
  end
end

defimpl FunWithFlags.Group, for: Gits.Auth.User do
  def in?(%{email: email}, :admins),
    do: Regex.match?(~r/@(bar.com|gits.co.za)$/, email)
end
