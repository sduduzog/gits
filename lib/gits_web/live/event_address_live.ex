defmodule GitsWeb.EventAddressLive do
  require Ash.Query
  alias Gits.Storefront.Event
  use GitsWeb, :live_view
  import GitsWeb.DashboardComponents

  def mount(_, session, socket) do
    params = session["params"]

    socket =
      assign(socket, :account_id, params["account_id"])
      |> assign(:event_id, params["event_id"])
      |> assign(:list, [])
      |> assign(:form, %{"query" => nil} |> to_form())

    {:ok, socket, layout: {GitsWeb.Layouts, :dashboard}}
  end

  def handle_event("select_place", unsigned_params, socket) do
    Event
    |> Ash.Query.filter(id: socket.assigns.event_id)
    |> Ash.read_one!()
    |> Ash.Changeset.for_update(:update_address, %{address_place_id: unsigned_params["id"]})
    |> Ash.update!()

    {:noreply,
     redirect(socket,
       to: ~p"/accounts/#{socket.assigns.account_id}/events/#{socket.assigns.event_id}/settings"
     )}
  end

  def handle_event("search", unsigned_params, socket) do
    list = get_places(unsigned_params["query"])

    {:noreply, assign(socket, :list, list)}
  end

  defp get_places(query) do
    Cachex.fetch(:cache, query, fn key ->
      config = Application.get_env(:gits, :google)

      Req.new(base_url: "https://places.googleapis.com")
      |> Req.Request.put_header("X-Goog-Api-Key", config[:maps_api_key])
      |> Req.post!(
        url: "/v1/places:autocomplete",
        json: %{input: key, regionCode: "za"}
      )
      |> Map.get(:body)
      |> Map.get("suggestions")
      |> case do
        suggestions when is_list(suggestions) ->
          {:commit,
           Enum.map(suggestions, fn
             %{"placePrediction" => prediction} ->
               structuredFormat = prediction["structuredFormat"]

               %{
                 place_id: prediction["placeId"],
                 main_text: structuredFormat["mainText"]["text"],
                 secondary_text: structuredFormat["secondaryText"]["text"]
               }
           end), ttl: :timer.hours(72)}

        _ ->
          {:ignore, []}
      end
    end)
    |> case do
      {:commit, list, _} -> list
      {:ok, list} -> list
      _ -> []
    end
  end
end
