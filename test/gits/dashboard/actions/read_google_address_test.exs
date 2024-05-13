defmodule Gits.Dashboard.Actions.ReadGoogleAddressTest do
  alias Gits.Dashboard.Actions.ReadGoogleAddress
  alias Gits.Dashboard.Venue.GoogleAddress
  use PowerAssert

  import Mock

  describe "transform_response_to_google_addresses/1" do
    test "returns ok tuble and list of %GoogleAddress resources from Req.Response" do
      fake_suggestion = %{
        "placePrediction" => %{
          "placeId" => "place_id",
          "mainText" => %{"text" => "foo"},
          "secondaryText" => %{"text" => "bar"}
        }
      }

      result =
        ReadGoogleAddress.transform_response_to_google_addresses(
          {:ok, %Req.Response{body: %{"suggestions" => [fake_suggestion]}}}
        )

      assert result ==
               {:ok, [%GoogleAddress{id: "place_id", main_text: "foo", secondary_text: "bar"}]}
    end

    test "returns error tuple with term when request failed" do
      result = ReadGoogleAddress.transform_response_to_google_addresses({:error, %Req.Response{}})

      assert result == {:error, :request_failed}
    end
  end
end
