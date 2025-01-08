defmodule Gits.Support.Conversation do
  use Ash.Resource, domain: Gits.Support, data_layer: AshPostgres.DataLayer

  postgres do
    repo Gits.Repo
    table "support_conversations"
  end

  attributes do
    uuid_primary_key :id
  end
end
