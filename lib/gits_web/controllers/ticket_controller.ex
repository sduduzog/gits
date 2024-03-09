defmodule GitsWeb.TicketController do
  use GitsWeb, :controller

  def index(conn, _) do
    text(conn, "tickets")
  end
end
