defmodule GitsWeb.EmailHTML do
  use GitsWeb, :html
  use GitsWeb, :verified_routes
  use PhoenixHTMLHelpers
  alias Gits.EmailTemplates

  def test(_assigns) do
    template =
      EmailTemplates.UserConfirmation.render(
        title: "Verify your email address",
        user_name: "Sdu",
        preview: "This is a preview",
        base_url: Application.get_env(:gits, :base_url),
        url: "/foo"
      )

    raw(template)
  end
end
