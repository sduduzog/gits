defmodule Gits.Support.Job do
  alias __MODULE__.Checks.{CanRead}

  use Ash.Resource,
    domain: Gits.Support,
    data_layer: AshPostgres.DataLayer,
    authorizers: Ash.Policy.Authorizer

  postgres do
    repo Gits.Repo
    table "oban_jobs"
    migrate? false
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  policies do
    policy action(:read) do
      authorize_if CanRead
    end
  end

  attributes do
    integer_primary_key :id

    attribute :worker, :string

    attribute :state, :atom,
      constraints: [
        one_of: [
          :available,
          :cancelled,
          :completed,
          :discarded,
          :executing,
          :retryable,
          :scheduled
        ]
      ]

    attribute :attempt, :integer
    attribute :scheduled_at, :utc_datetime
  end
end
