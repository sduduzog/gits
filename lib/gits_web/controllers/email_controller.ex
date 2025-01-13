defmodule GitsWeb.EmailController do
  require Decimal
  use GitsWeb, :controller

  def test(conn, _) do
    conn
    |> put_root_layout(false)
    |> put_layout(false)
    |> assign(:order_id, 1)
    |> assign(:event_name, "Glitter bomb")
    |> assign(:tickets_summary, [
      {"General", Decimal.new("30"), 3},
      {"VIP", Decimal.new("100"), 2}
    ])
    |> assign(:total, Decimal.new("30"))
    |> assign(:token, "foo")
    |> render(:order_completed)
  end
end
