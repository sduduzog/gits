defmodule Gits.Storefront.Calculations.HolderIdFromToken do
  use Ash.Resource.Calculation

  def calculate(records, _opts, %{arguments: %{token: token}}) do
    Enum.map(records, fn _record ->
      token
      |> ExBase58.decode()
      |> case do
        {:ok, decoded} ->
          [_, id] = decoded |> String.split(":")
          id

        _ ->
          nil
      end
    end)
  end
end
