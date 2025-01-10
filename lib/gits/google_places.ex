defmodule Gits.GooglePlaces do
  def get_suggestions(query, :cache) do
    Cachex.fetch(:cache, query, fn key ->
      get_suggestions(key)
      |> case do
        {:ok, suggestions} -> {:commit, suggestions}
        _ -> {:ignore, []}
      end
    end)
    |> case do
      {_, suggestions} -> {:ok, suggestions}
    end
  end

  def get_suggestions("") do
    {:ok, []}
  end

  def get_suggestions(query) do
    options = Application.get_env(:gits, :google_api_options)

    Req.new(options)
    |> Req.post(
      url: "/v1/places:autocomplete",
      json: %{input: query, regionCode: "za"}
    )
    |> case do
      {:ok, %Req.Response{status: 200, body: body}} ->
        {:ok, body}

      _ ->
        {:error, :issues_fetching_from_api}
    end
    |> format_suggestions()
  end

  defp format_suggestions({:ok, %{"suggestions" => suggestions}}) do
    suggestions =
      Enum.map(suggestions, fn %{"placePrediction" => placePrediction} ->
        %{id: placePrediction["placeId"], text: placePrediction["text"]["text"]}
      end)

    {:ok, suggestions}
  end

  def get_place_details(place_id, :cache) do
    Cachex.fetch(:cache, place_id, fn key ->
      get_place_details(key)
      |> case do
        {:ok, details} -> {:commit, details}
      end
    end)
    |> case do
      {_, details} -> {:ok, details}
    end
  end

  def get_place_details(place_id) do
    options = Application.get_env(:gits, :google_api_options)

    Req.new(options)
    |> Req.merge(
      headers: %{
        "X-Goog-FieldMask" =>
          "addressComponents,location,shortFormattedAddress,displayName,googleMapsLinks"
      }
    )
    |> Req.get(url: "/v1/places/#{place_id}")
    |> case do
      {:ok, %Req.Response{status: 200, body: body}} -> {:ok, body}
      _ -> {:error, :issues_fetching_from_api}
    end
    |> format_place_details()
  end

  defp format_place_details({:ok, body}) do
    {latitude, longitude} = location(body)

    {:ok,
     %{
       name: if(body["displayName"], do: body["displayName"]["text"], else: nil),
       place_uri: if(body["googleMapsLinks"], do: body["googleMapsLinks"]["placeUri"], else: nil),
       address: body["shortFormattedAddress"],
       surburb: component(body, ["sublocality_level_1", "sublocality", "political"]),
       city_or_town: component(body, ["locality", "political"]),
       province: component(body, ["administrative_area_level_1", "political"]),
       postal_code: component(body, ["postal_code"]),
       latitude: latitude,
       longitude: longitude
     }}
  end

  defp component(%{"addressComponents" => components}, types) do
    Enum.find(components, &(&1["types"] == types))
    |> case do
      %{"longText" => text} -> text
      nil -> nil
    end
  end

  defp location(%{"location" => location}) do
    {location["latitude"], location["longitude"]}
  end
end
