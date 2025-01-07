defmodule Gits.Support.Job do
  use Ash.Resource, domain: Gits.Support, data_layer: AshPostgres.DataLayer

  postgres do
    repo Gits.Repo
    table "oban_jobs"
    migrate? false
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  attributes do
    integer_primary_key :id

    attribute :worker, :string

    attribute :state, :atom, constraints: [one_of: [:completed]]

    attribute :attempt, :integer
    attribute :scheduled_at, :utc_datetime
  end
end
