defmodule GitsWeb.EmailHTML do
  use GitsWeb, :html
  use GitsWeb, :verified_routes
  use PhoenixHTMLHelpers
  alias Gits.EmailTemplates

  def test(_assigns) do
    # template =
    #   EmailTemplates.PasswordReset.render(
    #     title: "Reset your password",
    #     user_name: "Sdu",
    #     base_url: Application.get_env(:gits, :base_url),
    #     url: "/foo"
    #   )
    subject = "Complimentary ticket to The ZATechRadio 📻 Meet: Rooftop Edition"

    template =
      Gits.EmailTemplates.TicketInvite.render(
        title: subject,
        base_url: Application.get_env(:gits, :base_url),
        url: "/foo"
      )

    raw(template)
  end
end
