defmodule Gits.Accounts do
  use Ash.Domain, extensions: [AshPaperTrail.Domain]
  alias __MODULE__.{Host, Role, Token, User, UserIdentity, Venue, Webhook, WebhookEvent}

  resources do
    resource Host
    resource Host.Version
    resource Role
    resource Token
    resource User
    resource UserIdentity
    resource Venue
    resource Venue.Version
    resource Webhook
    resource Webhook.Version
    resource WebhookEvent
  end
end
