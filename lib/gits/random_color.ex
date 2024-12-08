defmodule Gits.RandomColor do
  def generate do
    :crypto.strong_rand_bytes(3)
    |> Base.encode16(case: :lower)
    |> String.pad_leading(7, "#")
  end
end
