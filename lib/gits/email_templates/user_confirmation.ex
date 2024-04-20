defmodule Gits.EmailTemplates.UserConfirmation do
  use MjmlEEx, mjml_template: "user_confirmation.mjml.eex", layout: Gits.EmailTemplates.BaseLayout
end
