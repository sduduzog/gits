defmodule Gits.DashboardTest do
  alias Ecto.Adapters.SQL.Sandbox
  alias Gits.Dashboard.Venue.DetailedGoogleAddress
  alias Gits.Dashboard.Venue.GoogleAddress
  use ExUnit.Case, async: true
  use ExUnitProperties

  import Mock

  setup_with_mocks([{Cachex, [], [fetch: fn _, key, callback -> callback.(key) end]}]) do
    :ok = Sandbox.checkout(Gits.Repo)
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

  describe "fetch_from_api" do
    test "returns a single record" do
      Req.Test.stub(:google_api, fn conn ->
        Req.Test.json(conn, %{
          "displayName" => %{"languageCode" => "en", "text" => "A Streetbar Named Desire"},
          "googleMapsUri" => "https://maps.google.com/?cid=7460301463055742669",
          "id" => "abc",
          "primaryType" => "bar",
          "primaryTypeDisplayName" => %{"languageCode" => "en-US", "text" => "Bar"},
          "shortFormattedAddress" => "144 Jan Smuts Ave, Parkwood, Randburg"
        })
      end)

      assert {:ok, %DetailedGoogleAddress{}} =
               Gits.Dashboard.fetch_address_from_api("abc")
    end

    test "returns record for address without primary type" do
      Req.Test.stub(:google_api, fn conn ->
        Req.Test.json(conn, %{
          "displayName" => %{"languageCode" => "en", "text" => "Midrand"},
          "googleMapsUri" => "https://maps.google.com/?cid=9777895728776740386",
          "id" => "ChIJixllSf1xlR4RIv6LHFwQsoc",
          "shortFormattedAddress" => "Midrand"
        })

        assert {:ok, %DetailedGoogleAddress{}} = Gits.Dashboard.fetch_address_from_api("abc")
      end)
    end
  end
end
