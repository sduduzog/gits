defmodule Gits.DashboardTest do
  alias Gits.Dashboard.Venue.GoogleAddress
  # use PowerAssert
  use ExUnit.Case, async: true

  import Mock

  setup_with_mocks([{Cachex, [], [fetch: fn _, key, callback -> callback.(key) end]}]) do
    :ok
  end

  describe "search_for_address" do
    test "should return found addresses as Gits.Dashboard.Venue.GoogleAddress list" do
      Req.Test.stub(:google_api, fn conn ->
        Req.Test.json(
          conn,
          %{
            "suggestions" => [
              %{
                "placePrediction" => %{
                  "placeId" => "place_id",
                  "structuredFormat" => %{
                    "mainText" => %{"text" => "foo"},
                    "secondaryText" => %{"text" => "bar"}
                  }
                }
              }
            ]
          }
        )
      end)

      result = Gits.Dashboard.search_for_address("mea")

      assert result ==
               {:ok,
                [
                  %GoogleAddress{
                    id: "place_id",
                    main_text: "foo",
                    secondary_text: "bar",
                    __metadata__: %{selected: [:id, :main_text, :secondary_text]}
                  }
                ]}
    end
  end
end
