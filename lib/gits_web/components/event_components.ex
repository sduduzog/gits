defmodule GitsWeb.EventComponents do
  use GitsWeb, :html

  embed_templates "event_components/*"

  defp get_feature_image(account_id, event_id) do
    get_image(account_id, event_id, "feature")
  end

  def get_image(account_id, event_id, type) do
    filename = "#{account_id}/#{event_id}/#{type}.jpg"

    ExAws.S3.head_object("gits", filename)
    |> ExAws.request()
    |> case do
      {:ok, _} -> "/bucket/#{filename}"
      _ -> "/images/placeholder.png"
    end
  end

  defp get_address(place_id) do
    Cachex.fetch(:cache, place_id, fn key ->
      config = Application.get_env(:gits, :google)

      Req.new(base_url: "https://places.googleapis.com")
      |> Req.Request.put_header("X-Goog-Api-Key", config[:maps_api_key])
      |> Req.Request.put_header(
        "X-Goog-FieldMask",
        "displayName,formattedAddress,location"
      )
      |> Req.get!(url: "/v1/places/#{key}")
      |> Map.get(:body)
      |> case do
        %{"displayName" => name, "formattedAddress" => address, "location" => location} ->
          {:commit,
           %{
             name: name["text"],
             address: address,
             location: %{lat: location["latitude"], long: location["longitude"]}
           }}

        _ ->
          {:ignore, nil}
      end
    end)
    |> case do
      {:commit, place, _} ->
        place

      {:commit, place} ->
        place

      {:ok, place} ->
        place

      _ ->
        nil
    end
  end
end
