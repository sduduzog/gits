defmodule Gits.Storefront.Order do
  use Ash.Resource,
    domain: Gits.Storefront,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshStateMachine]

  postgres do
    table "orders"
    repo Gits.Repo
  end

  state_machine do
    initial_states [:anonymous, :open]
    default_initial_state :anonymous
  end

  actions do
    defaults [:read, create: []]
  end

  attributes do
    uuid_primary_key :id
  end
end
