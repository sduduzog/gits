defmodule Gits.Support do
  alias __MODULE__.{Admin, Conversation, Job, Ticket}
  use Ash.Domain

  resources do
    resource Admin
    resource Conversation
    resource Job
    resource Ticket
  end
end
