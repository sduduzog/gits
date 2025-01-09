defmodule GitsWeb.EmailController do
  require Decimal
  use GitsWeb, :controller

  def test(conn, _) do
    conn
    |> put_root_layout(false)
    |> put_layout(false)
    |> assign(:order_no, 1)
    |> assign(:event_name, "Glitter bomb")
    |> assign(:tickets_summary, [{"General", Decimal.new("30"), 3}])
    |> assign(:total, Decimal.new("30"))
    |> render(:order_completed)
  end
end
