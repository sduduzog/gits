defmodule GitsWeb.EmailHTML do
  use GitsWeb, :html
  use GitsWeb, :verified_routes

  def test(_assigns) do
    template = Gits.EmailTemplates.render_magic_link("/test")
    raw(template)
  end
end
