defmodule Gits.Accounts.RoleType do
  use Ash.Type.Enum,
    values: [
      owner: "Can transer or close the account. Has administrator priviledges",
      administrator: "Oversees the entire account. Payment management to handle financial issues",
      event_organizer: "Creates and manages events, tickets and attendees",
      moderator: "Manage live event sessions and troubleshoot issues"
    ]
end
