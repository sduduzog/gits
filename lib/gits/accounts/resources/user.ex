defmodule Gits.Accounts.User do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshAuthentication]

  attributes do
    uuid_primary_key :id
    attribute :email, :ci_string, allow_nil?: false
    attribute :hashed_password, :string, allow_nil?: false, sensitive?: true
    attribute :display_name, :string, allow_nil?: false
    attribute :avatar, :string, allow_nil?: true
  end

  authentication do
    api Gits.Accounts

    add_ons do
      confirmation :confirm do
        monitor_fields [:email]
        sender Gits.Accounts.User.Senders.AccountConfirmationSender
      end
    end

    strategies do
      password :password do
        identity_field :email
        sign_in_tokens_enabled? true
        confirmation_required? false
      end
    end

    tokens do
      enabled? true
      token_resource Gits.Accounts.Token

      signing_secret Gits.Accounts.Secrets
    end
  end

  postgres do
    table "users"
    repo Gits.Repo
  end

  identities do
    identity :unique_email, [:email] do
      eager_check_with Gits.Accounts
    end
  end

  actions do
    defaults [:read]
  end
end
