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
