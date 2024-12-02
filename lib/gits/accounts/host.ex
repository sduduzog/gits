defmodule Gits.Accounts.Host do
  alias Gits.Accounts.PaystackSubaccount
  alias Gits.PaystackApi
  alias Gits.Accounts
  alias Gits.Accounts.{Role, User}

  use Ash.Resource,
    domain: Gits.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource]

  postgres do
    repo Gits.Repo
    table "hosts"
  end

  actions do
    defaults [:read, :destroy, update: :*]

    create :create do
      primary? true
      accept [:name, :logo]

      argument :owner, :map do
        allow_nil? false
      end

      change manage_relationship(:owner, type: :append)
      change set_attribute(:handle, &Nanoid.generate/0)
    end

    update :paystack_subaccount do
      require_atomic? false

      argument :paystack_business_name, :string, allow_nil?: false
      argument :paystack_settlement_bank, :string, allow_nil?: false
      argument :paystack_account_number, :string, allow_nil?: false

      change fn changeset, _ ->
        business_name = Ash.Changeset.get_argument(changeset, :paystack_business_name)
        account_number = Ash.Changeset.get_argument(changeset, :paystack_account_number)
        settlement_bank = Ash.Changeset.get_argument(changeset, :paystack_settlement_bank)

        if changeset.data.paystack_subaccount_code do
          Ash.Changeset.before_transaction(changeset, fn changeset ->
            code = changeset.data.paystack_subaccount_code

            PaystackApi.update_subaccount(
              code,
              business_name,
              account_number,
              settlement_bank,
              :cache
            )

            changeset
          end)
        else
          Ash.Changeset.before_transaction(changeset, fn changeset ->
            PaystackApi.create_subaccount(business_name, account_number, settlement_bank)
            |> case do
              {:ok, subaccount} ->
                Ash.Changeset.force_change_attribute(
                  changeset,
                  :paystack_subaccount_code,
                  subaccount.subaccount_code
                )
            end
          end)
        end
      end
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, public?: true, allow_nil?: false

    attribute :handle, :string,
      public?: true,
      allow_nil?: false,
      constraints: [match: ~r"^[a-z0-9](-?[a-z0-9])*$", min_length: 3]

    attribute :logo, :string, public?: true

    attribute :paystack_subaccount_code, :string, public?: true

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :owner, User do
      domain Accounts
      allow_nil? false
    end

    has_many :roles, Role
  end

  calculations do
    calculate :paystack_subaccount, :map, fn records, _ ->
      Enum.map(records, fn record ->
        PaystackApi.fetch_subaccount(record.paystack_subaccount_code, :cache)
        |> case do
          {:ok, subaccount} ->
            %{
              business_name: subaccount.business_name,
              account_number: subaccount.account_number,
              settlement_bank: subaccount.settlement_bank
            }

          _ ->
            nil
        end
      end)
    end

    calculate :paystack_business_name, :string, fn records, _ ->
      Enum.map(records, fn record ->
        record = Ash.load!(record, [:paystack_subaccount])

        case record.paystack_subaccount do
          nil -> nil
          subaccount -> subaccount.business_name
        end
      end)
    end

    calculate :paystack_account_number, :string, fn records, _ ->
      Enum.map(records, fn record ->
        record = Ash.load!(record, [:paystack_subaccount])

        case record.paystack_subaccount do
          nil -> nil
          subaccount -> subaccount.account_number
        end
      end)
    end

    calculate :paystack_settlement_bank, :string, fn records, _ ->
      Enum.map(records, fn record ->
        record = Ash.load!(record, [:paystack_subaccount])

        case record.paystack_subaccount do
          nil -> nil
          subaccount -> subaccount.settlement_bank
        end
      end)
    end
  end
end
