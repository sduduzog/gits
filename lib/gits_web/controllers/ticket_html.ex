defmodule GitsWeb.TicketHTML do
  use GitsWeb, :html
  use PhoenixHTMLHelpers
  import GitsWeb.DashboardComponents

  embed_templates "ticket_html/*"
end
