defmodule Gits.Dashboard.Actions.ReadGoogleAddressTest do
  use ExUnit.Case

  require Ash.Query
  alias Gits.Dashboard.Actions.ReadGoogleAddress
  alias Gits.Dashboard.Venue.DetailedGoogleAddress

  describe "details_response_to_address/1" do
    test "returns venue with primary type" do
      response =
        {:ok,
         %Req.Response{
           body: %{
             "displayName" => %{"languageCode" => "en", "text" => "name"},
             "googleMapsUri" => "uri",
             "id" => "abc",
             "primaryType" => "bar",
             "shortFormattedAddress" => "addy"
           }
         }}

      assert {:ok,
              [
                %DetailedGoogleAddress{
                  id: "abc",
                  name: "name",
                  google_maps_uri: "uri",
                  formatted_address: "addy",
                  type: "bar"
                }
              ]} =
               ReadGoogleAddress.details_response_to_address(response)
    end

    test "returns venue without primary type" do
      response =
        {:ok,
         %Req.Response{
           body: %{
             "displayName" => %{"languageCode" => "en", "text" => "name"},
             "googleMapsUri" => "uri",
             "id" => "abc",
             "shortFormattedAddress" => "addy"
           }
         }}

      assert {:ok,
              [
                %DetailedGoogleAddress{
                  id: "abc",
                  name: "name",
                  formatted_address: "addy",
                  google_maps_uri: "uri"
                }
              ]} =
               ReadGoogleAddress.details_response_to_address(response)
    end
  end
end
