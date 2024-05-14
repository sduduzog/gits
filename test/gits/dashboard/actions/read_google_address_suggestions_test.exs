defmodule Gits.Dashboard.Actions.ReadGoogleAddressSuggestionsTest do
  use PowerAssert

  require Ash.Query
  alias Gits.Dashboard.Actions.ReadGoogleAddressSuggestions
  alias Gits.Dashboard.Venue.GoogleAddress

  describe "prepare_response_for_cache/1" do
    test "returns ignore tuple when input is ok" do
      result = ReadGoogleAddressSuggestions.prepare_response_for_cache({:ok, %{test: "foo"}})

      assert result == {:commit, %{test: "foo"}, ttl: :timer.hours(72)}
    end

    test "returns ignore tuple when input is error" do
      result = ReadGoogleAddressSuggestions.prepare_response_for_cache({:error, %{test: "bar"}})

      assert result == {:ignore, %{test: "bar"}}
    end
  end

  describe "prepare_response_from_cache/1" do
    test "should return ok and result from commit tuple" do
      result = ReadGoogleAddressSuggestions.prepare_response_from_cache({:commit, :test})

      assert result == {:ok, :test}
    end

    test "should return ok and result from commit tuple with options" do
      result =
        ReadGoogleAddressSuggestions.prepare_response_from_cache(
          {:commit, :test, ttl: :timer.hours(1)}
        )

      assert result == {:ok, :test}
    end

    test "should return ok and result from ok tuple" do
      result = ReadGoogleAddressSuggestions.prepare_response_from_cache({:ok, :test})

      assert result == {:ok, :test}
    end

    test "should return error and result from ignore tuple" do
      result = ReadGoogleAddressSuggestions.prepare_response_from_cache({:ignore, :test})

      assert result == {:error, :test}
    end

    test "should passthrough error and result from error tuple" do
      result = ReadGoogleAddressSuggestions.prepare_response_from_cache({:error, :test})

      assert result == {:error, :test}
    end
  end

  describe "transform_response_to_google_addresses/1" do
    test "returns ok tuple and list of %GoogleAddress resources from Req.Response" do
      fake_suggestion = %{
        "placePrediction" => %{
          "placeId" => "place_id",
          "structuredFormat" => %{
            "mainText" => %{"text" => "foo"},
            "secondaryText" => %{"text" => "bar"}
          }
        }
      }

      result =
        ReadGoogleAddressSuggestions.transform_response_to_google_addresses(
          {:ok, %Req.Response{body: %{"suggestions" => [fake_suggestion]}}}
        )

      assert result ==
               {:ok, [%GoogleAddress{id: "place_id", main_text: "foo", secondary_text: "bar"}]}
    end

    test "returns ok tuple if address does not have secondary text" do
      fake_suggestion = %{
        "placePrediction" => %{
          "placeId" => "place_id",
          "structuredFormat" => %{
            "mainText" => %{"text" => "foo"}
          }
        }
      }

      result =
        ReadGoogleAddressSuggestions.transform_response_to_google_addresses(
          {:ok, %Req.Response{body: %{"suggestions" => [fake_suggestion]}}}
        )

      assert result ==
               {:ok, [%GoogleAddress{id: "place_id", main_text: "foo", secondary_text: nil}]}
    end

    test "returns error tuple with term when request failed" do
      result =
        ReadGoogleAddressSuggestions.transform_response_to_google_addresses(
          {:error, %Req.Response{}}
        )

      assert result == {:error, :request_failed}
    end

    test "returns error tuple if request failed" do
      fake_suggestion = %{
        "placePrediction" => %{
          "placeId" => "place_id",
          "structuredFormat" => %{
            "mainText" => %{"text" => "foo"}
          }
        }
      }

      result =
        ReadGoogleAddressSuggestions.transform_response_to_google_addresses(
          {:ok, %Req.Response{body: %{"error" => %{"message" => "test message"}}}}
        )

      assert result ==
               {:error, :request_failed}
    end
  end
end
