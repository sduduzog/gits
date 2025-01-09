defmodule GitsWeb.EventComponents do
  use Phoenix.Component
  use GitsWeb, :verified_routes

  embed_templates "event_templates/*"
end
