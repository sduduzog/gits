defmodule GitsWeb.HostLive.Orders do
  require Ash.Query
  alias Gits.Storefront.Order
  alias Gits.Accounts.User
  alias Gits.Accounts.Host
  use GitsWeb, :live_view

  def mount(%{"handle" => handle}, _, socket) do
    user = socket.assigns.current_user

    Ash.load(
      user,
      [
        hosts:
          Ash.Query.filter(Host, handle == ^handle)
          |> Ash.Query.load(
            orders:
              Ash.Query.filter(Order, state not in [:anonymous, :open, :cancelled])
              |> Ash.Query.sort(number: :desc)
          )
      ],
      actor: user
    )
    |> case do
      {:ok, %User{hosts: [%Host{orders: orders}]}} ->
        socket
        |> assign(:orders, orders)
        |> ok(:host)
    end
  end
end
