defmodule GitsWeb.EventLive do
  alias Gits.Storefront.Customer
  alias Gits.Storefront.TicketInstance
  alias Gits.Storefront.Ticket
  use GitsWeb, :live_view
  require Ash.Query
  alias Gits.Storefront.Event

  def mount(params, _, socket) do
    customer =
      case socket.assigns.current_user do
        user when is_struct(user) ->
          Ash.Changeset.for_create(Customer, :create, %{user_id: user.id}, actor: user)
          |> Ash.create!()

        nil ->
          nil
      end

    event =
      Ash.Query.for_read(Event, :masked, %{id: params["id"]}, actor: customer)
      |> Ash.Query.load([:address])
      |> Ash.read_one!()

    unless event do
      raise GitsWeb.Exceptions.NotFound
    end

    tickets =
      Ash.Query.for_read(Ticket, :read)
      |> Ash.Query.filter(event == event)
      |> Ash.Query.load([:customer_instance_count])
      |> Ash.read!(actor: customer)

    socket =
      socket
      |> assign(:customer, customer)
      |> assign(:event, event)
      |> assign(:tickets, tickets)

    {:ok, socket}
  end

  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  def handle_event("remove_ticket", unsigned_params, socket) do
    customer = socket.assigns.customer

    Ash.Query.for_read(TicketInstance, :read, %{}, actor: customer)
    |> Ash.Query.filter(ticket.id == ^unsigned_params["id"])
    |> Ash.Query.limit(1)
    |> Ash.read_one!()
    |> Ash.destroy!(actor: customer)

    event = socket.assigns.event

    tickets =
      Ash.Query.for_read(Ticket, :read)
      |> Ash.Query.filter(event.id == ^event.id)
      |> Ash.Query.load(:customer_instance_count)
      |> Ash.read!(actor: customer)

    socket =
      socket
      |> assign(:tickets, tickets)

    {:noreply, socket}
  end

  def handle_event("add_ticket", unsigned_params, socket) do
    if socket.assigns.current_user do
      ticket = Ash.get!(Ticket, unsigned_params["id"])
      event = socket.assigns.event
      customer = socket.assigns.customer

      Ash.Changeset.for_create(
        TicketInstance,
        :create,
        %{
          ticket: ticket,
          customer: customer
        },
        actor: customer
      )
      |> Ash.create!()

      tickets =
        Ash.Query.for_read(Ticket, :read, %{}, actor: customer)
        |> Ash.Query.filter(event.id == ^event.id)
        |> Ash.Query.load(:customer_instance_count)
        |> Ash.read!()

      socket =
        socket
        |> assign(:tickets, tickets)

      {:noreply, socket}
    else
      {:noreply,
       redirect(socket,
         to: ~p"/register?return_to=#{~p"/events/#{socket.assigns.event.masked_id}"}"
       )}
    end
  end

  defp get_feature_image(account_id, event_id) do
    get_image(account_id, event_id, "feature")
  end

  def get_image(account_id, event_id, type) do
    filename = "#{account_id}/#{event_id}/#{type}.jpg"

    ExAws.S3.head_object("gits", filename)
    |> ExAws.request()
    |> case do
      {:ok, _} -> "/bucket/#{filename}"
      _ -> "/images/placeholder.png"
    end
  end
end
