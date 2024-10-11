defmodule GitsWeb.HostLive.GetStarted do
  alias Gits.Hosts.Host
  alias AshPhoenix.Form
  use GitsWeb, :host_live_view

  def mount(_params, _session, socket) do
    socket
    |> assign(:uploaded_files, [])
    |> allow_upload(:logo, accept: ~w(.jpg .jpeg .png .webp), max_entries: 1)
    |> assign(:page_title, "Get started")
    |> ok(:host_panel)
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-xl">
      <h1 class="text-2xl font-semibold">Sign up as a host</h1>
      <p class="mt-2 text-sm text-gray-700">
        As a host, you'll be able to manage events, tickets and venues, invite team members and more.
      </p>
    </div>
    <.form
      :let={f}
      for={@form}
      class="mx-auto grid max-w-xl grid-cols-2 gap-6 pt-4"
      phx-change="validate"
      phx-submit="save"
    >
      <div class="col-span-full space-y-2">
        <label class="col-span-full grid gap-1">
          <span class="text-sm font-medium">Host name</span>
          <input
            name={f[:name].name}
            value={f[:name].value}
            type="text"
            class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm"
          />
        </label>

        <label class="col-span-full grid gap-1">
          <div class="flex items-center rounded-lg border border-zinc-300 pl-3">
            <span class="text-sm text-zinc-500">gits.co.za/h/</span>
            <input
              type="text"
              name={f[:handle].name}
              value={f[:handle].value}
              class="w-full rounded-lg border-none py-2 pl-0 pr-3 text-sm focus-visible:ring-0"
            />
            <.icon :if={false} name="hero-check-micro" class="mr-3 shrink-0 text-green-500" />
            <.icon :if={false} name="hero-x-mark-micro" class="mr-3 shrink-0 text-red-500" />
            <.icon
              :if={false}
              name="hero-arrow-path-micro"
              class="mr-3 shrink-0 animate-spin text-zinc-400"
            />
          </div>
        </label>
      </div>

      <div class="col-span-full grid grid-cols-[auto_1fr] items-center gap-1 gap-x-4">
        <span class="col-span-full w-full text-sm font-medium">Upload your logo</span>
        <div class="size-24 overflow-hidden rounded-xl bg-zinc-200">
          <%= if Enum.any?(@uploads.logo.entries) do %>
            <.live_img_preview
              entry={@uploads.logo.entries |> List.first()}
              class="h-full w-full object-cover"
            />
          <% else %>
            <img src="/images/placeholder.png" alt="" class="h-full w-full object-cover" />
          <% end %>
        </div>
        <div class="inline-grid">
          <label class="inline-flex">
            <span class="sr-only">Choose logo</span>
            <.live_file_input
              upload={@uploads.logo}
              class="w-full text-sm font-medium file:mr-4 file:h-9 file:rounded-lg file:border file:border-solid file:border-zinc-300 file:bg-white file:px-4 file:py-2 hover:file:bg-zinc-50"
            />
          </label>
        </div>
      </div>
      <div class="col-span-full flex justify-end gap-6">
        <button class="rounded-lg bg-zinc-900 px-4 py-2 text-zinc-50" type="submit">
          <span class="text-sm font-semibold">Sign up</span>
        </button>
      </div>
    </.form>
    """
  end

  def handle_params(_unsigned_params, _uri, socket) do
    %{current_user: user} = socket.assigns

    socket
    |> assign(
      :form,
      Host
      |> Form.for_create(:create, as: "host", actor: user)
      |> Form.validate(%{"handle" => Nanoid.generate()}, target: ["handle"])
    )
    |> noreply()
  end

  def handle_event("validate", unsigned_params, socket) do
    %{form: form} = socket.assigns

    socket
    |> assign(
      :form,
      form
      |> Form.validate(unsigned_params["host"],
        target: unsigned_params["_target"]
      )
      |> IO.inspect()
    )
    |> noreply()
  end

  def handle_event("save", _unsigned_params, socket) do
    %{form: form} = socket.assigns

    [_logo_filename] =
      consume_uploaded_entries(socket, :logo, fn %{path: path}, _entry ->
        bucket_name = Application.get_env(:gits, :bucket_name)

        filename = Nanoid.generate(24) <> ".jpg"

        Image.open!(path)
        |> Image.thumbnail!("256x256", fit: :cover)
        |> Image.stream!(suffix: ".jpg", buffer_size: 5_242_880, quality: 100)
        |> ExAws.S3.upload(
          bucket_name,
          filename,
          content_type: "image/jpeg",
          cache_control: "public,max-age=3600"
        )
        |> ExAws.request()

        {:ok, filename}
      end)

    socket |> noreply()
  end

  def handle_event("close", _unsigned_params, socket) do
    socket
    |> push_navigate(to: ~p"/host-with-us", replace: true)
    |> noreply()
  end
end
