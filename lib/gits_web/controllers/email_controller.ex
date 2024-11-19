defmodule GitsWeb.EmailController do
  use GitsWeb, :controller

  def test(conn, _) do
    conn
    |> put_root_layout(false)
    |> put_layout(false)
    |> assign(:token, "foo")
    |> render(:order_confirmation)
  end
end
