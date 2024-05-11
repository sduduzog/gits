defmodule GitsWeb.TeamMemberHTML do
  use GitsWeb, :html
  use PhoenixHTMLHelpers
  import GitsWeb.DashboardComponents

  embed_templates "team_member_html/*"
end
