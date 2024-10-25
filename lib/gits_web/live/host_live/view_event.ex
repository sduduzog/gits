defmodule GitsWeb.HostLive.ViewEvent do
  alias Gits.Hosts.Event
  alias Gits.Hosts.Host
  use GitsWeb, :host_live_view
  require Ash.Query

  def mount(params, _session, socket) do
    host =
      Host
      |> Ash.Query.filter(handle == ^params["handle"])
      |> Ash.read_first!()

    socket
    |> assign(:host_handle, host.handle)
    |> assign(:host_name, host.name)
    |> assign(:host_logo, host.logo)
    |> assign(:page_title, "The Ultimate Cheese Festival")
    |> ok()
  end

  def handle_params(%{"event_id" => event_id} = unsigned_params, _uri, socket) do
    Event
    |> Ash.Query.filter(public_id == ^event_id)
    |> Ash.Query.load(:details)
    |> Ash.read_one()
    |> case do
      {:ok, event} -> socket |> assign(:event, event) |> assign(:event_id, event_id)
    end
    |> show_publish_modal(unsigned_params)
    |> noreply()
  end

  def handle_event("publish", unsigned_params, socket) do
    unsigned_params |> IO.inspect()
    socket |> noreply()
  end

  defp show_publish_modal(socket, %{"publish" => _event_id}) do
    socket
    |> assign(:show_publish_modal, true)
  end

  defp show_publish_modal(socket, _) do
    socket
    |> assign(:show_publish_modal, false)
  end
end
