defmodule GitsWeb.Layouts do
  alias GitsWeb.HostLive.{Dashboard, ListEvents, ViewEvent}
  use GitsWeb, :html

  embed_templates "layouts/*"
end
