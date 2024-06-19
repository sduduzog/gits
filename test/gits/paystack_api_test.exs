defmodule Gits.PaystackApiTest do
  use ExUnit.Case, async: true
  import Mock

  describe "list_banks/0" do
    test "should list formatted banks from ok response" do
      Req.Test.stub(:paystack_api, fn conn ->
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

      assert {:ok, [%{id: 140, name: "Absa Bank Limited, South Africa", code: "632005"}]} =
               Gits.PaystackApi.list_banks()
    end
  end

  describe "create_subaccount/3" do
    test_with_mock "should create subaccount and return the new record",
                   Gits.PaystackApi,
                   [:passthrough],
                   list_banks: fn -> {:ok, [%{id: 140, name: "test_bank", code: "123456"}]} end do
      Req.Test.stub(:paystack_api, fn conn ->
        Req.Test.json(
          conn,
          %{
            "status" => true,
            "message" => "Subaccount created",
            "data" => %{
              "account_number" => "23402352035",
              "active" => true,
              "bank" => 140,
              "business_name" => "Test",
              "createdAt" => "2024-05-30T03:43:56.248Z",
              "currency" => "ZAR",
              "domain" => "test",
              "id" => 1_090_020,
              "integration" => 1_189_131,
              "is_verified" => false,
              "managed_by_integration" => 1_189_131,
              "migrate" => false,
              "percentage_charge" => 99,
              "product" => "collection",
              "settlement_bank" => "Absa Bank Limited, South Africa",
              "settlement_schedule" => "AUTO",
              "subaccount_code" => "ACCT_wcifesxscsi3q1r",
              "updatedAt" => "2024-05-30T03:43:56.248Z"
            }
          }
        )
      end)

      assert {:ok,
              %{
                subaccount_code: "ACCT_wcifesxscsi3q1r",
                account_number: "23402352035",
                business_name: "Test",
                settlement_bank: "123456",
                percentage_charge: 99
              }} =
               Gits.PaystackApi.create_subaccount("", "", "")
    end
  end

  describe "update_subaccount/3" do
    test_with_mock "should update subaccount and return the new record",
                   Gits.PaystackApi,
                   [:passthrough],
                   list_banks: fn -> {:ok, [%{id: 140, name: "test_bank", code: "123456"}]} end do
      Req.Test.stub(:paystack_api, fn conn ->
        Req.Test.json(
          conn,
          %{
            "status" => true,
            "message" => "Subaccount updated",
            "data" => %{
              "account_number" => "23402352035",
              "active" => true,
              "bank" => 140,
              "business_name" => "Test",
              "createdAt" => "2024-05-30T03:43:56.248Z",
              "currency" => "ZAR",
              "domain" => "test",
              "id" => 1_090_020,
              "integration" => 1_189_131,
              "is_verified" => false,
              "managed_by_integration" => 1_189_131,
              "migrate" => false,
              "percentage_charge" => 99,
              "product" => "collection",
              "settlement_bank" => "Absa Bank Limited, South Africa",
              "settlement_schedule" => "AUTO",
              "subaccount_code" => "ACCT_wcifesxscsi3q1r",
              "updatedAt" => "2024-05-30T03:43:56.248Z"
            }
          }
        )
      end)

      assert {:ok,
              %{
                subaccount_code: "ACCT_wcifesxscsi3q1r",
                account_number: "23402352035",
                business_name: "Test",
                settlement_bank: "123456",
                percentage_charge: 99
              }} =
               Gits.PaystackApi.update_subaccount("code", "", "", "")
    end
  end
end
