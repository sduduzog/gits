defmodule Gits.Dashboard.Actions.ReadGoogleAddress do
  alias Gits.Dashboard.Venue.GoogleAddress
  use Ash.Resource.ManualRead

  def read(query, _data_layer_query, _opts, _context) do
    fetch_suggestions_from_cache(query.arguments.query)
    |> transform_response_to_google_addresses()
  end

  defp fetch_suggestions_from_cache(query) do
    Cachex.fetch(:cache, query, fn key ->
      fetch_suggestions_from_api(key)
      |> prepare_response_for_cache()
    end)
    |> prepare_response_from_cache()
  end

  defp fetch_suggestions_from_api(query) do
    options = Application.get_env(:gits, :google_api_options)

    Req.new(options)
    |> Req.post(
      url: "/v1/places:autocomplete",
      json: %{input: query, regionCode: "za"}
    )
  end

  def prepare_response_for_cache(response) do
    case response do
      {:ok, result} -> {:commit, result, ttl: :timer.hours(72)}
      {:error, result} -> {:ignore, result}
    end
  end

  def prepare_response_from_cache(response) do
    case response do
      {:ok, result} -> {:ok, result}
      {:commit, result} -> {:ok, result}
      {:commit, result, _} -> {:ok, result}
      {:ignore, result} -> {:error, result}
      {:error, result} -> {:error, result}
    end
  end

  def transform_response_to_google_addresses(response) do
    case response do
      {:ok, %Req.Response{body: %{"suggestions" => suggestions}}} ->
        {:ok, Enum.map(suggestions, &suggestion_to_google_address/1)}

      {:ok, %Req.Response{body: %{"error" => _}}} ->
        {:error, :request_failed}

      {:error, _} ->
        {:error, :request_failed}
    end
  end

  defp suggestion_to_google_address(suggestion) do
    %{
      "placePrediction" => %{
        "placeId" => place_id,
        "structuredFormat" => structuredFormat
      }
    } = suggestion

    case structuredFormat do
      %{"mainText" => %{"text" => main_text}, "secondaryText" => %{"text" => secondary_text}} ->
        %GoogleAddress{
          id: place_id,
          main_text: main_text,
          secondary_text: secondary_text
        }

      %{"mainText" => %{"text" => main_text}} ->
        %GoogleAddress{
          id: place_id,
          main_text: main_text,
          secondary_text: nil
        }
    end
  end
end
