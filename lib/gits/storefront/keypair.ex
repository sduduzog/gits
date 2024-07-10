defmodule Gits.Storefront.Keypair do
  alias Salty.Sign.Ed25519

  use Ash.Resource,
    data_layer: AshPostgres.DataLayer,
    domain: Gits.Storefront

  attributes do
    attribute :private_key, :string, allow_nil?: false, public?: true

    attribute :public_key, :string, allow_nil?: false, public?: true
    attribute :pk, :binary, allow_nil?: false, public?: true
    attribute :sk, :binary, allow_nil?: false, public?: true

    create_timestamp :created_at, public?: true
    update_timestamp :updated_at, public?: true
  end

  relationships do
    belongs_to :event, Gits.Storefront.Event do
      allow_nil? false
      attribute_type :integer
      primary_key? true
    end
  end

  calculations do
  end

  actions do
    defaults [:read, :destroy, update: :*]

    create :create do
      primary? true

      change fn changeset, %{actor: actor} ->
        changeset
        |> Ash.Changeset.before_action(fn changeset ->
          {:ok, pk, sk} =
            Ed25519.keypair()

          changeset
          |> Ash.Changeset.change_attribute(:public_key, pk)
          |> Ash.Changeset.change_attribute(:secret_key, sk)
        end)
      end
    end
  end

  postgres do
    table "keypairs"
    repo Gits.Repo
  end
end
