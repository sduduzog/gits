defmodule Gits.EmailTemplates.TicketInvite do
  use MjmlEEx, mjml_template: "ticket_invite.mjml.eex", layout: Gits.EmailTemplates.BaseLayout
end
