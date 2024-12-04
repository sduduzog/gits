defmodule GitsWeb.TicketLive do
  require Ash.Query
  alias Gits.Storefront.Ticket
  use GitsWeb, :live_view

  def mount(params, _session, socket) do
    Ash.Query.filter(Ticket, public_id == ^params["public_id"])
    |> Ash.Query.load(ticket_type: :event)
    |> Ash.read_one()
    |> case do
      {:ok, ticket} ->
        socket |> assign(:ticket, ticket)
    end
    |> ok()
  end
end
