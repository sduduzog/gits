defmodule Gits.Currency do
  require Decimal

  def format(input) do
    cond do
      is_integer(input) ->
        input |> Decimal.new() |> format()

      is_float(input) ->
        input |> Decimal.from_float() |> format()

      Decimal.is_decimal(input) ->
        input
        |> Decimal.round(2)
        |> Decimal.to_string(:normal)
        |> format()

      String.contains?(input, ".") ->
        [whole_number | fraction_part] = input |> String.split(".")
        Enum.join([whole_number |> format(), fraction_part], ".")

      String.length(input) > 3 ->
        length = String.length(input)
        start = length - 3

        Enum.join(
          [
            input |> String.slice(0, start) |> format(),
            input |> String.slice(start, length)
          ],
          " "
        )

      true ->
        input
    end
  end
end
