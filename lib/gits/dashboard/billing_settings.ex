defmodule Gits.Dashboard.BillingSettings do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    domain: Gits.Dashboard

  alias Gits.Dashboard.Account

  attributes do
    uuid_primary_key :id
    attribute :paystack_subbaccount_code, :string, public?: true
    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :account, Account
  end

  calculations do
    calculate :paystack_ready?, :boolean, expr(not is_nil(paystack_subbaccount_code))
  end

  actions do
    defaults [:read, create: :*]

    update :create_paystack_subaccount do
      require_atomic? false

      argument :business_name, :string, allow_nil?: false
      argument :account_number, :string, allow_nil?: false
      argument :settlement_bank, :string, allow_nil?: false

      change before_action(fn changeset, _ ->
               Gits.PaystackApi.create_subaccount(
                 Ash.Changeset.get_argument(changeset, :business_name),
                 Ash.Changeset.get_argument(changeset, :account_number),
                 Ash.Changeset.get_argument(changeset, :settlement_bank)
               )
               |> case do
                 {:ok, account} ->
                   Ash.Changeset.change_new_attribute(
                     changeset,
                     :paystack_subbaccount_code,
                     account.subaccount_code
                   )

                 _ ->
                   Ash.Changeset.add_error(changeset, field: :test, message: "test error message")
               end
             end)
    end
  end

  policies do
    policy action(:create) do
      authorize_if accessing_from(Account, :billing_settings)
    end

    policy action(:create_paystack_subaccount) do
      authorize_if expr(
                     account.members.user.id == ^actor(:id) and
                       account.members.role in [:owner, :admin]
                   )
    end

    policy action([:read, :create, :create_paystack_subaccount]) do
      authorize_if actor_present()
    end
  end

  postgres do
    table "billing_settings"
    repo Gits.Repo
  end
end
