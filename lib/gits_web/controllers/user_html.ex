defmodule GitsWeb.UserHTML do
  use GitsWeb, :html
  use PhoenixHTMLHelpers
  import GitsWeb.DashboardComponents

  embed_templates "user_html/*"
end
