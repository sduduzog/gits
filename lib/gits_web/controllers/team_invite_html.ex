defmodule GitsWeb.TeamInviteHTML do
  use GitsWeb, :html
  use PhoenixHTMLHelpers
  import GitsWeb.DashboardComponents

  embed_templates "team_invite_html/*"
end
