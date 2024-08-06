defmodule Gits.GoogleApi.Places do
  def search_for_suggestions("") do
    :empty
  end

  def search_for_suggestions(query) do
    request_auto_complete(query)
  end

  def fetch_place_details(place_id) do
    request_place(place_id)
    |> body_from_response()
    |> place_details_from_body()
  end

  defp request_place(place_id) do
    options = Application.get_env(:gits, :google_api_options)

    Req.new(options)
    |> Req.merge(
      headers: %{
        "X-Goog-FieldMask" =>
          "id,displayName,googleMapsUri,primaryType,shortFormattedAddress,addressComponents"
      }
    )
    |> Req.get(url: "/v1/places/#{place_id}")
  end

  defp place_details_from_body(
         {:ok,
          %{
            "id" => place_id,
            "shortFormattedAddress" => short_format_address,
            "addressComponents" => address_components,
            "googleMapsUri" => google_maps_uri,
            "displayName" => %{
              "text" => display_name
            }
          }}
       ) do
    city = resolve_city_from_address_components(address_components)
    province = resolve_province_from_address_components(address_components)

    {:ok,
     %{
       city: city,
       place_id: place_id,
       province: province,
       display_name: display_name,
       google_maps_uri: google_maps_uri,
       short_format_address: short_format_address
     }}
  end

  defp resolve_city_from_address_components(address_components) do
    address_components
    |> Enum.find(fn component -> component["types"] == ["locality", "political"] end)
    |> Map.get("longText")
  end

  defp resolve_province_from_address_components(address_components) do
    address_components
    |> Enum.find(fn component ->
      component["types"] == ["administrative_area_level_1", "political"]
    end)
    |> Map.get("longText")
  end

  defp request_auto_complete(query) do
    options = Application.get_env(:gits, :google_api_options)

    Req.new(options)
    |> Req.post(
      url: "/v1/places:autocomplete",
      json: %{input: query, regionCode: "za"}
    )
    |> body_from_response()
    |> suggestions_from_body()
  end

  defp body_from_response({:ok, %Req.Response{body: body}}) do
    {:ok, body}
  end

  defp suggestions_from_body({:ok, %{"suggestions" => suggestions}}) do
    {:ok,
     suggestions
     |> Enum.map(&parse_suggestion/1)
     |> Enum.flat_map(fn element ->
       case element do
         :parse_error -> []
         element -> [element]
       end
     end)}
  end

  defp suggestions_from_body({:ok, %{}}) do
    {:ok, []}
  end

  defp parse_suggestion(%{
         "placePrediction" => %{
           "placeId" => place_id,
           "structuredFormat" => %{
             "mainText" => %{"text" => main_text},
             "secondaryText" => %{"text" => secondary_text}
           }
         }
       }) do
    %{id: place_id, main_text: main_text, secondary_text: secondary_text}
  end

  defp parse_suggestion(_) do
    :parse_error
  end
end
