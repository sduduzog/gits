defmodule Gits.Cache do
  def get_address(place_id) do
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
