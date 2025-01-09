defmodule Gits.Support.Ticket do
  use Ash.Resource, domain: Gits.Support, data_layer: AshPostgres.DataLayer

  postgres do
    repo Gits.Repo
    table "support_tickets"
  end

  attributes do
    integer_primary_key :id
    attribute :subject, :string, public?: true, allow_nil?: false
  end
end
