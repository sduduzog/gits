defmodule Gits.CurrencyTest do
  use ExUnit.Case, async: true

  alias Gits.Currency

  describe "format" do
    test "delimeter in the formating with double digit fraction for decimals" do
      assert "1,00" = Currency.format(1)
      assert "1,01" = Currency.format(1.01)
      assert "1,10" = Currency.format(1.1)
      assert "1,00" = Currency.format(1)
      assert "10,10" = Currency.format(10.1)
      assert "1 234,10" = Currency.format(1234.1)
      assert "1 023 456 789,00" = Currency.format(1_023_456_789)
      assert "1 023 456 789,55" = Currency.format(1_023_456_789.545)
    end
  end
end
