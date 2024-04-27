defmodule GitsWeb.AttendeeHTML do
  use GitsWeb, :html
  use PhoenixHTMLHelpers
  import GitsWeb.DashboardComponents

  embed_templates "attendee_html/*"
end
