defmodule Gits.Dashboard.Actions.ReadGoogleAddress do
  alias Gits.Dashboard.Venue.DetailedGoogleAddress
  use Ash.Resource.ManualRead

  def read(query, _data_layer_query, _opts, _context) do
    fetch_place_details_from_cache(query.arguments.id)
    |> details_response_to_address()
  end

  def fetch_place_details(place_id) do
    options = Application.get_env(:gits, :google_api_options)

    Req.new(options)
    |> Req.merge(
      headers: %{
        "X-Goog-FieldMask" => "id,displayName,googleMapsUri,primaryType,shortFormattedAddress"
      }
    )
    |> Req.get(url: "/v1/places/#{place_id}")
  end

  defp fetch_place_details_from_cache(query) do
    Cachex.fetch(:cache, query, fn key ->
      fetch_place_details(key)
      |> prepare_response_for_cache()
    end)
    |> prepare_response_from_cache()
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

  def details_response_to_address({:ok, %Req.Response{body: body}}) do
    %{
      "id" => id,
      "displayName" => %{"text" => display_name},
      "googleMapsUri" => uri,
      "shortFormattedAddress" => formatted_address
    } = body

    venue = %DetailedGoogleAddress{
      id: id,
      name: display_name,
      google_maps_uri: uri,
      formatted_address: formatted_address
    }

    venue =
      case body do
        %{"primaryType" => type} -> %{venue | type: type}
        _ -> venue
      end

    {:ok, [venue]}
  end

  def details_response_to_address(response_tuple) do
    response_tuple
  end
end
