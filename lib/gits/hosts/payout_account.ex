defmodule Gits.Hosts.PayoutAccount do
  alias Gits.Hosts.Host

  use Ash.Resource,
    domain: Gits.Hosts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource]

  postgres do
    table "payout_accounts"
    repo Gits.Repo
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  attributes do
    uuid_primary_key :id
    attribute :business_name, :string, allow_nil?: false
    attribute :account_number, :string, allow_nil?: false
    attribute :settlement_bank, :string, allow_nil?: false
    attribute :percentage_charge, :decimal, allow_nil?: false, default: 1.1

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :host, Host
  end
end
