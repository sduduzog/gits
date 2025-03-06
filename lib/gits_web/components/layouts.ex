defmodule GitsWeb.Layouts do
  use GitsWeb, :html
  import GitsWeb.DashboardComponents

  embed_templates "layouts/*"
end
