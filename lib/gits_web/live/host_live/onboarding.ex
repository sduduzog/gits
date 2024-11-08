defmodule GitsWeb.HostLive.Onboarding do
  require Ash.Query
  alias Gits.Hosting.Host
  alias AshPhoenix.Form

  use GitsWeb, :live_view

  def render(%{live_action: :get_started} = assigns) do
    ~H"""
    <div class="w-full max-w-screen-sm">
      <h1 class="text-2xl font-semibold">Create a host account</h1>
      <p class="mt-4 text-zinc-500">
        A host account will make it easy to manage events, venues, your team and everything else to make you a successful host
      </p>
      <.form :let={f} for={@form} phx-submit="save">
        <div class="grid grid-cols-[auto_1fr] mt-8 items-center gap-1 gap-x-4">
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
          <div class="inline-grid gap-4">
            <label class="inline-flex">
              <span class="sr-only">Choose logo</span>
              <.live_file_input
                upload={@uploads.logo}
                class="w-full text-sm font-medium file:mr-4 file:h-9 file:rounded-lg file:border file:border-solid file:border-zinc-300 file:bg-white file:px-4 file:py-2 hover:file:bg-zinc-50"
              />
            </label>
            <span class="text-sm text-zinc-500">
              .png, .jpeg, .gif files up to 2MB. Recommended size is 256x256
            </span>
          </div>
        </div>

        <label class="col-span-full grid gap-1 mt-8">
          <span class="text-sm font-medium">Host name</span>
          <input
            name={f[:name].name}
            value={f[:name].value}
            type="text"
            class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm"
          />
        </label>
        <div class="mt-8">
          <button class="h-9 rounded-lg px-4 py-2 text-sm font-semibold bg-zinc-950 text-zinc-50">
            Continue
          </button>
        </div>
      </.form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Create a host account")
    |> assign(:uploaded_files, [])
    |> allow_upload(:logo, accept: ~w(.jpg .jpeg .png .webp), max_entries: 1)
    |> ok(:host_panel)
  end

  def handle_params(_unsigned_params, _uri, socket) do
    %{current_user: user} = socket.assigns

    Host
    |> Ash.Query.filter(owner.id == ^user.id)
    |> Ash.read()
    |> case do
      {:ok, [host]} ->
        socket
        |> push_navigate(to: ~p"/hosts/#{host.handle}/dashboard")
        |> noreply()

      _ ->
        socket
        |> assign(
          :form,
          Host
          |> Form.for_create(:create, as: "host", actor: user)
          |> Form.validate(%{"handle" => Nanoid.generate()}, target: ["handle"])
        )
        |> noreply()
    end
  end

  def handle_event("close", _unsigned_params, socket) do
    socket |> push_navigate(to: ~p"/") |> noreply()
  end

  def handle_event("save", unsigned_params, socket) do
    %{form: form, current_user: user} = socket.assigns

    filename =
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
      |> case do
        [filename] ->
          filename

        [] ->
          nil
      end

    form
    |> Form.validate(Map.merge(unsigned_params["host"], %{"logo" => filename, owner: user}))
    |> Form.submit()
    |> case do
      {:ok, host} -> socket |> push_navigate(to: ~p"/hosts/#{host.handle}/events/create-new")
      _ -> socket
    end
    |> noreply()
  end
end
