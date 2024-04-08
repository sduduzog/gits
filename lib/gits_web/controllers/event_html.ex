defmodule GitsWeb.EventHTML do
  use GitsWeb, :html
  use PhoenixHTMLHelpers
  import GitsWeb.DashboardComponents

  embed_templates "event_html/*"
end
