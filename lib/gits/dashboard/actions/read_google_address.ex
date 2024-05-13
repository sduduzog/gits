defmodule Gits.Dashboard.Actions.ReadGoogleAddress do
  alias Gits.Dashboard.Venue.GoogleAddress
  use Ash.Resource.ManualRead

  def read(query, _data_layer_query, _opts, _context) do
    query_key = query.arguments.query

    raw_results =
      Cachex.fetch(:cache, query_key, fn key ->
        options = Application.get_env(:gits, :google_api_options)

        Req.new(options)
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
                   id: prediction["placeId"],
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

    {:ok,
     Enum.map(raw_results, fn result ->
       %GoogleAddress{
         id: result.id,
         main_text: result.main_text,
         secondary_text: result.secondary_text
       }
     end)}
  end
end
