defmodule Gits.Dashboard.Account do
  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    domain: Gits.Dashboard

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :paystack_subbaccount_code, :string, public?: true
    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :members, Gits.Dashboard.Member

    has_many :events, Gits.Storefront.Event do
      domain Gits.Storefront
    end
  end

  actions do
    default_accept :*
    defaults [:read, :destroy, update: :*]

    create :create do
      primary? true
      accept :*

      argument :member, :map

      argument :event, :map

      change manage_relationship(:member, :members, type: :create)
      change manage_relationship(:event, :events, type: :create)
    end

    create :create_from_waitlist do
      accept :*

      argument :member, :map

      change manage_relationship(:member, :members, on_lookup: {:relate_and_update, :activate})
    end

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
    policy action(:read) do
      authorize_if always()
    end

    policy action(:create_from_waitlist) do
      authorize_if Gits.Checks.ActorIsObanJob
    end

    policy action(:create_paystack_subaccount) do
      authorize_if actor_present()
    end

    policy action(:create) do
      authorize_if actor_present()
    end
  end

  postgres do
    table "accounts"
    repo Gits.Repo
  end
end
