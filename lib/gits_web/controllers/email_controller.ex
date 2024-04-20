defmodule GitsWeb.EmailController do
  use GitsWeb, :controller

  def test(conn, _) do
    conn |> put_layout(false) |> render(:test)
  end
end
