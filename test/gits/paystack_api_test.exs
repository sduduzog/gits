defmodule Gits.PaystackApiTest do
  use ExUnit.Case, async: true

  describe "transform_list_banks_response/0" do
    test "" do
      Req.Test.stub(:google_api, fn conn ->
        Req.Test.json(
          conn,
          %{
            "data" => [
              %{
                "active" => true,
                "code" => "632005",
                "country" => "South Africa",
                "createdAt" => "2020-09-04T10:38:56.000Z",
                "currency" => "ZAR",
                "gateway" => nil,
                "id" => 140,
                "is_deleted" => false,
                "longcode" => "632005",
                "name" => "Absa Bank Limited, South Africa",
                "pay_with_bank" => false,
                "slug" => "absa-za",
                "supports_transfer" => true,
                "type" => "basa",
                "updatedAt" => nil
              }
            ],
            "status" => true
          }
        )
      end)
    end
  end
end
