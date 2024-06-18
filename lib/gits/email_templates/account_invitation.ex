defmodule Gits.EmailTemplates.AccountInvitation do
  use MjmlEEx,
    mjml_template: "account_invitation.mjml.eex",
    layout: Gits.EmailTemplates.BaseLayout
end
