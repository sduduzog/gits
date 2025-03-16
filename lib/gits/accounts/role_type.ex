defmodule Gits.Accounts.RoleType do
  use Ash.Type.Enum,
    values: [
      # event_promoter: "Promotes events through marketing channels",
      # ticketing_manager: "Manages ticket sales and refunds",
      # content_manager: "Manages event content and listings",
      # customer_support_specialist: "Handles customer inquiries and issues",
      # financial_analyst: "Analyzes financial data for events",
      # venue_coordinator: "Manages venue logistics and relationships",
      # sponsorship_manager: "Secures and manages sponsorships for events",
      # marketing_analyst: "Analyzes marketing campaign effectiveness",
      # event_reporter: "Provides real-time event coverage",
      security_officer: "Oversees event security measures",
      # event_organizer: "Creates and manages events, tickets and attendees",
      # moderator: "Manage live event sessions and troubleshoot issues",
      # administrator: "Oversees the entire account. Payment management to handle financial issues",
      owner: "Can transer or close the account. Has administrator priviledges"
    ]
end
