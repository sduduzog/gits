defmodule Gits.Hosts.Event do
  alias Gits.Hosts.{Host, PayoutAccount}

  use Ash.Resource,
    domain: Gits.Hosts,
    extensions: [AshArchival.Resource]

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  attributes do
    uuid_primary_key :id

    attribute :public_id, :string, allow_nil?: false

    attribute :payout_schedule, :atom, constraints: [one_of: [:auto, :manual]]

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :host, Host

    belongs_to :payout_account, PayoutAccount
  end
end
