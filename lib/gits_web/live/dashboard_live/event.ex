defmodule GitsWeb.DashboardLive.Event do
  use GitsWeb, :live_view

  alias AshPhoenix.Form
  alias Gits.Dashboard.Account
  alias Gits.Storefront.Event
  alias Gits.Storefront.Ticket

  def mount(params, _session, socket) do
    user = socket.assigns.current_user

    socket =
      socket
      |> assign(:slug, params["slug"])

    accounts =
      Account
      |> Ash.Query.for_read(:list_for_dashboard, %{user_id: user.id}, actor: user)
      |> Ash.read!()

    account = Enum.find(accounts, fn item -> item.id == params["slug"] end)

    event =
      Event
      |> Ash.Query.for_read(:read, %{id: params["event_id"]}, actor: user)
      |> Ash.Query.load(:tickets)
      |> Ash.read_one!()

    socket =
      socket
      |> assign(:slug, params["slug"])
      |> assign(:title, "Settings")
      |> assign(:accounts, accounts)
      |> assign(:account, account)
      |> assign(:account_name, account.name)
      |> assign(:event, event)
      |> assign(:title, event.name)
      |> assign(:context_options, [%{label: "Tickets"}])
      |> assign(:manage_ticket_form, nil)
      |> assign(:manage_ticket_title, nil)

    {:ok, socket, layout: {GitsWeb.Layouts, :dashboard}}
  end

  def handle_params(%{"ticket" => "new"}, _uri, socket) do
    form = Ticket |> Form.for_create(:create, as: "ticket", actor: socket.assigns.current_user)

    socket =
      socket
      |> assign(:manage_ticket_form, form)
      |> assign(:manage_ticket_title, "Create a new ticket")

    {:noreply, socket}
  end

  def handle_params(_, _uri, socket) do
    socket =
      socket
      |> assign(:manage_ticket_form, nil)
      |> assign(:manage_ticket_title, nil)

    {:noreply, socket}
  end

  def handle_event("submit", %{"ticket" => params}, socket) do
    socket =
      socket.assigns.manage_ticket_form
      |> Form.validate(Map.put(params, :event, socket.assigns.event))
      |> Form.submit()
      |> case do
        {:ok, _} ->
          socket
          |> push_patch(
            to: ~p"/accounts/#{socket.assigns.slug}/events/#{socket.assigns.event.id}"
          )

        {:error, form} ->
          IO.inspect(form)
          socket |> assign(:manage_ticket_form, form)
      end

    {:noreply, socket}
  end
end
