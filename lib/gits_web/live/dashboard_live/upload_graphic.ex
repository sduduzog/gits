defmodule GitsWeb.DashboardLive.UploadGraphic do
  use GitsWeb, :dashboard_live_view

  alias Gits.Dashboard.Member
  alias Gits.Storefront.Event

  def handle_params(unsigned_params, _uri, socket) do
    %{current_user: user, account: account} = socket.assigns

    account =
      account
      |> Ash.load!(
        [
          events:
            Event
            |> Ash.Query.for_read(:read)
            |> Ash.Query.filter(id == ^unsigned_params["event_id"])
        ],
        actor: user
      )

    [event] = account.events

    socket
    |> assign(:event_id, unsigned_params["event_id"])
    |> assign(:event_name, event.name)
    |> allow_upload(:feature_image, accept: ~w(.jpg .jpeg .png), max_entries: 1)
    |> allow_upload(:listing_image, accept: ~w(.jpg .jpeg .png), max_entries: 1)
    |> noreply()
  end

  def handle_event("save_feature_image", _unsigned_params, socket) do
    consume_uploaded_entries(socket, :feature_image, fn %{path: path}, _entry ->
      Image.open!(path)
      |> Image.thumbnail!("480x320", fit: :cover)
      |> Image.stream!(suffix: ".jpg", buffer_size: 5_242_880, quality: 100)
      |> Gits.Bucket.upload_feature_image(socket.assigns.account.id, socket.assigns.event_id)

      {:ok, nil}
    end)

    {:noreply, socket}
  end

  def handle_event("save_listing_image", _unsigned_params, socket) do
    consume_uploaded_entries(socket, :listing_image, fn %{path: path}, _entry ->
      Image.open!(path)
      |> Image.thumbnail!("256x320", fit: :cover)
      |> Image.stream!(suffix: ".jpg", buffer_size: 5_242_880, quality: 100)
      |> Gits.Bucket.upload_listing_image(socket.assigns.account.id, socket.assigns.event_id)

      {:ok, nil}
    end)

    {:noreply, socket}
  end

  def handle_event("validate", _unsigned_params, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-start gap-2 md:flex-row">
      <.link
        navigate={~p"/accounts/#{@slug}/events"}
        class="text-sm flex gap-2 text-zinc-400 hover:text-zinc-700"
      >
        <.icon name="hero-chevron-left-mini" />
        <span>Events</span>
      </.link>

      <.link
        navigate={~p"/accounts/#{@slug}/events/#{@event_id}"}
        class="flex gap-2 text-sm text-zinc-400 hover:text-zinc-700"
      >
        <.icon name="hero-slash-mini" />
        <span><%= @event_name %></span>
      </.link>

      <div class="flex gap-2 text-sm text-zinc-600">
        <.icon name="hero-slash-mini" />
        <span>Upload graphics</span>
      </div>
    </div>
    <h1 class="px-4 text-xl font-semibold">Upload graphics</h1>

    <.form
      for={%{}}
      class="border justify-between flex-wrap gap-4 flex relative p-4 rounded-xl"
      phx-change="validate"
      phx-submit="save_feature_image"
    >
      <div class="flex flex-col items-start gap-4">
        <h2 class="text-lg font-medium">Feature image</h2>
        <.live_file_input
          upload={@uploads.feature_image}
          class="file:p-2 file:bg-zinc-100 file:px-4 w-full file:rounded-2xl file:border-0"
        />
        <button class="rounded-2xl bg-zinc-100 p-2 px-4">
          Upload
        </button>
      </div>
      <div class="aspect-[3/2] w-64 overflow-hidden rounded-md border *:h-full *:w-full *:object-cover">
        <img
          :if={[] == @uploads.feature_image.entries}
          src={Gits.Bucket.get_feature_image_path(@account.id, @event_id)}
          alt="featured image preview"
        />
        <%= for entry <- @uploads.feature_image.entries do %>
          <.live_img_preview entry={entry} />
        <% end %>
      </div>
    </.form>

    <.form
      for={%{}}
      class="border justify-between flex gap-4 flex-wrap relative p-4 rounded-xl"
      phx-change="validate"
      phx-submit="save_listing_image"
    >
      <div class=" flex flex-col items-start gap-4">
        <h2 class="text-lg font-medium">Listing image</h2>
        <.live_file_input
          upload={@uploads.listing_image}
          class="file:p-2 file:bg-zinc-100 file:px-4 w-full file:rounded-2xl file:border-0"
        />
        <button class="rounded-2xl bg-zinc-100 p-2 px-4">
          Upload
        </button>
      </div>
      <div class="aspect-[4/5] w-52 overflow-hidden rounded-md border *:h-full *:w-full *:object-cover">
        <img
          :if={[] == @uploads.listing_image.entries}
          src={Gits.Bucket.get_listing_image_path(@account.id, @event_id)}
          alt="listing image preview"
        />
        <%= for entry <- @uploads.listing_image.entries do %>
          <.live_img_preview entry={entry} />
        <% end %>
      </div>
    </.form>
    """
  end
end
