defmodule Gits.Hosting do
  use Ash.Domain

  alias __MODULE__.{
    Host,
    Role,
    Venue,
    PayoutAccount
  }

  resources do
    resource Host
    resource Role
    resource Venue
    resource PayoutAccount
  end
end
