defmodule GitsWeb.DashboardLive.UploadGraphic do
  require Ash.Query
  use GitsWeb, :live_view

  alias Gits.Dashboard.{Account, Member}
  alias Gits.Storefront.Event

  def mount(params, _session, socket) do
    user = socket.assigns.current_user

    accounts =
      Account
      |> Ash.Query.for_read(:list_for_dashboard, %{user_id: user.id}, actor: user)
      |> Ash.read!()
      |> Enum.map(fn item -> %{id: item.id, name: item.name} end)

    account = Enum.find(accounts, fn item -> item.id == params["slug"] end)

    members =
      Member
      |> Ash.Query.for_read(:read_for_dashboard, %{}, actor: user)
      |> Ash.read!()

    event =
      Event
      |> Ash.Query.for_read(:read, %{id: params["event_id"]}, actor: user)
      |> Ash.Query.load([:tickets, :account])
      |> Ash.read_one!()

    socket =
      socket
      |> assign(:slug, params["slug"])
      |> assign(:title, "Team")
      |> assign(:context_options, nil)
      |> assign(:action, params["action"])
      |> assign(:accounts, accounts)
      |> assign(:account_id, account.id)
      |> assign(:account_name, account.name)
      |> assign(:event_id, event.id)
      |> assign(:event_name, event.name)
      |> assign(:members, members)
      |> allow_upload(:feature_image, accept: ~w(.jpg .jpeg .png), max_entries: 1)
      |> allow_upload(:listing_image, accept: ~w(.jpg .jpeg .png), max_entries: 1)

    {:ok, socket, layout: {GitsWeb.Layouts, :dashboard}}
  end

  def handle_event("save_feature_image", _unsigned_params, socket) do
    consume_uploaded_entries(socket, :feature_image, fn %{path: path}, _entry ->
      Image.open!(path)
      |> Image.thumbnail!("480x320", fit: :cover)
      |> Image.stream!(suffix: ".jpg", buffer_size: 5_242_880, quality: 100)
      |> Gits.Bucket.upload_feature_image(socket.assigns.account_id, socket.assigns.event_id)

      {:ok, nil}
    end)

    {:noreply, socket}
  end

  def handle_event("save_listing_image", _unsigned_params, socket) do
    consume_uploaded_entries(socket, :listing_image, fn %{path: path}, _entry ->
      Image.open!(path)
      |> Image.thumbnail!("256x320", fit: :cover)
      |> Image.stream!(suffix: ".jpg", buffer_size: 5_242_880, quality: 100)
      |> Gits.Bucket.upload_listing_image(socket.assigns.account_id, socket.assigns.event_id)

      {:ok, nil}
    end)

    {:noreply, socket}
  end

  def handle_event("validate", _unsigned_params, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="flex gap-2">
      <.link navigate={~p"/accounts/#{@slug}/events"} class="text-sm flex gap-2 text-zinc-400">
        <.icon name="hero-chevron-left-mini" />
        <span>Events</span>
      </.link>

      <.link
        navigate={~p"/accounts/#{@slug}/events/#{@event_id}"}
        class="text-sm flex gap-2 text-zinc-600"
      >
        <.icon name="hero-slash-mini" />
        <span><%= @event_name %></span>
      </.link>
    </div>
    <h1 class="px-4 text-xl font-semibold">Upload graphics</h1>

    <.form
      for={%{}}
      class="border justify-between flex relative p-4 rounded-xl"
      phx-change="validate"
      phx-submit="save_feature_image"
    >
      <div class="flex flex-col items-start gap-4">
        <h2 class="text-lg font-medium">Feature image</h2>
        <.live_file_input
          upload={@uploads.feature_image}
          class="file:p-2 file:bg-zinc-100 file:px-4 file:rounded-2xl file:border-0"
        />
        <button class="rounded-2xl bg-zinc-100 p-2 px-4">
          Upload
        </button>
      </div>
      <div class="aspect-[3/2] w-64 overflow-hidden rounded-md border *:h-full *:w-full *:object-cover">
        <img
          :if={[] == @uploads.feature_image.entries}
          src={Gits.Bucket.get_feature_image_path(@account_id, @event_id)}
          alt=""
        />
        <%= for entry <- @uploads.feature_image.entries do %>
          <.live_img_preview entry={entry} />
        <% end %>
      </div>
    </.form>

    <.form
      for={%{}}
      class="border justify-between flex relative p-4 rounded-xl"
      phx-change="validate"
      phx-submit="save_listing_image"
    >
      <div class="flex flex-col items-start gap-4">
        <h2 class="text-lg font-medium">Listing image</h2>
        <.live_file_input
          upload={@uploads.listing_image}
          class="file:p-2 file:bg-zinc-100 file:px-4 file:rounded-2xl file:border-0"
        />
        <button class="rounded-2xl bg-zinc-100 p-2 px-4">
          Upload
        </button>
      </div>
      <div class="aspect-[4/5] w-52 overflow-hidden rounded-md border *:h-full *:w-full *:object-cover">
        <img
          :if={[] == @uploads.listing_image.entries}
          src={Gits.Bucket.get_listing_image_path(@account_id, @event_id)}
          alt=""
        />
        <%= for entry <- @uploads.listing_image.entries do %>
          <.live_img_preview entry={entry} />
        <% end %>
      </div>
    </.form>
    """
  end
end
