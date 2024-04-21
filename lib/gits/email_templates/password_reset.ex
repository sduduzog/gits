defmodule Gits.EmailTemplates.PasswordReset do
  use MjmlEEx, mjml_template: "password_reset.mjml.eex", layout: Gits.EmailTemplates.BaseLayout
end
