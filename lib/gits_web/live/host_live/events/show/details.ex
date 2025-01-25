defmodule GitsWeb.HostLive.Events.Show.Details do
  require Ash.Query
  alias Gits.Storefront.Event
  alias Gits.Bucket.Image
  alias AshPhoenix.Form
  use GitsWeb, :live_component

  def update(assigns, socket) do
    Ash.load(assigns.event, poster: [:url])
    |> case do
      {:ok, %Event{} = event} ->
        socket
        |> assign(:event, event)
        |> assign(:submit_action, "update")
        |> assign(
          :form,
          Form.for_update(event, :details, actor: assigns.current_user, forms: [auto?: true])
        )

      _ ->
        socket
        |> assign(:submit_action, "create")
        |> assign(
          :form,
          Form.for_create(Event, :create, forms: [auto?: true], actor: assigns.current_user)
          |> Form.add_form([:host], type: :read, validate?: false)
        )
    end
    |> assign(:uploaded_files, [])
    |> assign(:poster, nil)
    |> allow_upload(:poster,
      accept: ~w(.jpg .jpeg .png .webp),
      max_entries: 1,
      max_file_size: 1_048_576 * 2,
      auto_upload: true,
      progress: &handle_progress/3
    )
    |> assign(:current_user, assigns.current_user)
    |> assign(:handle, assigns.handle)
    |> assign(:host_state, assigns.host_state)
    |> assign(:host_id, assigns.host_id)
    |> ok()
  end

  def handle_event("validate", unsigned_params, socket) do
    socket
    |> assign(:form, Form.validate(socket.assigns.form, unsigned_params["form"]))
    |> noreply()
  end

  def handle_event("update", unsigned_params, socket) do
    Form.submit(socket.assigns.form,
      params: unsigned_params["form"],
      action_opts: [load: [poster: [:url]]]
    )
    |> case do
      {:ok, event} ->
        send(self(), {:updated_event, event})

        socket
        |> assign(:event, event)
        |> assign(
          :form,
          Form.for_update(event, :details,
            actor: socket.assigns.current_user,
            forms: [auto?: true]
          )
        )
        |> noreply()

      {:error, form} ->
        socket
        |> assign(:form, form |> IO.inspect())
        |> noreply()
    end
  end

  def handle_event("create", unsigned_params, socket) do
    Form.submit(socket.assigns.form, params: unsigned_params["form"])
    |> case do
      {:ok, event} ->
        socket
        |> push_patch(
          to: ~p"/hosts/#{socket.assigns.handle}/events/#{event.public_id}/details",
          replace: true
        )
        |> noreply()

      {:error, form} ->
        socket
        |> assign(:form, form)
        |> noreply()
    end
  end

  defp handle_progress(:poster, entry, socket) do
    if entry.done? do
      [image] =
        consume_uploaded_entries(socket, :poster, fn %{path: path}, _entry ->
          Ash.Changeset.for_create(Image, :poster, %{path: path},
            actor: socket.assigns.current_user
          )
          |> Ash.create(load: [:url])
          |> case do
            {:ok, image} ->
              {:ok, image}

            _ ->
              {:ok, nil}
          end
        end)

      form =
        if Form.has_form?(socket.assigns.form, [:poster]) do
          Form.update_form(socket.assigns.form, [:poster], fn form ->
            Form.set_data(form, image)
          end)
        else
          Form.add_form(socket.assigns.form, [:poster],
            type: :read,
            data: image
          )
        end

      socket
      |> assign(:form, form)
      |> noreply()
    else
      socket |> noreply()
    end
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
