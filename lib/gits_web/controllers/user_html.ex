defmodule GitsWeb.UserHTML do
  alias Gits.Storefront.Event
  use GitsWeb, :html

  embed_templates "user_html/*"
end
