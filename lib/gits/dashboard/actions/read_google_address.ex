defmodule Gits.Dashboard.Actions.ReadGoogleAddress do
  alias Gits.Dashboard.Venue.GoogleAddress
  use Ash.Resource.ManualRead

  def read(query, _data_layer_query, _opts, _context) do
    fetch_suggestions_from_api(query.arguments.query)
    |> transform_response_to_google_addresses()
  end

  defp read_from_cache(query_key) do
    # Cachex.fetch(:cache, query_key, fn key ->
    # options = Application.get_env(:gits, :google_api_options)
    #
    # Req.new(options)
    # |> Req.post!(
    #   url: "/v1/places:autocomplete",
    #   json: %{input: key, regionCode: "za"}
    # )
    # |> Map.get(:body)
    # |> Map.get("suggestions")
    # |> case do
    #   suggestions when is_list(suggestions) ->
    #     {:commit,
    #      Enum.map(suggestions, fn
    #        %{"placePrediction" => prediction} ->
    #          structuredFormat = prediction["structuredFormat"]
    #
    #          %{
    #            id: prediction["placeId"],
    #            main_text: structuredFormat["mainText"]["text"],
    #            secondary_text: structuredFormat["secondaryText"]["text"]
    #          }
    #      end), ttl: :timer.hours(72)}
    #
    #   _ ->
    #     {:ignore, []}
    # end
    #   {:commit, [], ttl: :timer.hours(72)}
    # end)
    # |> case do
    #   {:commit, list, _} -> list
    #   {:ok, list} -> list
    #   _ -> []
  end

  defp fetch_suggestins_from_cache(query) do
    query
  end

  defp fetch_suggestions_from_api(query) do
    options = Application.get_env(:gits, :google_api_options)

    Req.new(options)
    |> Req.post(
      url: "/v1/places:autocomplete",
      json: %{input: query, regionCode: "za"}
    )
  end

  def transform_response_to_google_addresses(response) do
    case response do
      {:ok, %Req.Response{body: body}} ->
        %{"suggestions" => suggestions} = body
        {:ok, Enum.map(suggestions, &suggestion_to_google_address/1)}

      {:error, _} ->
        {:error, :request_failed}
    end
  end

  defp suggestion_to_google_address(suggestion) do
    %{
      "placePrediction" => %{
        "placeId" => place_id,
        "mainText" => main_text,
        "secondaryText" => secondary_text
      }
    } = suggestion

    %GoogleAddress{
      id: place_id,
      main_text: main_text["text"],
      secondary_text: secondary_text["text"]
    }
  end
end
