defmodule GitsWeb.AccountHTML do
  use GitsWeb, :html
  use PhoenixHTMLHelpers

  import GitsWeb.DashboardComponents

  embed_templates "account_html/*"
end
