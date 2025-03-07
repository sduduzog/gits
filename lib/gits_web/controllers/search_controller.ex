defmodule GitsWeb.SearchController do
  use GitsWeb, :controller

  def index(conn, _params) do
    conn
    |> assign(:current_tab, :search)
    |> assign(:page_title, "Search")
    |> assign(:events, [])
    |> render(:index)
  end
end
