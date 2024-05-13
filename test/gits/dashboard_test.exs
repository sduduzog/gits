defmodule DashboardTest do
  use ExUnit.Case

  describe "search for address" do
    test "returns empty list when no empty query passed" do
      Req.Test.stub(:google_api, fn conn -> Req.Test.json(conn, []) end)
      assert Gits.Dashboard.search_for_address("") == {:ok, []}
    end
  end
end
