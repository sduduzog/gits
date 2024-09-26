defmodule Gits.Documentation.Article do
  @enforce_keys [:id, :title, :content]
  defstruct [:id, :title, :content]

  def build(filename, attrs, body) do
    [id] = filename |> Path.rootname() |> Path.split() |> Enum.take(-1)

    struct!(__MODULE__, [id: id, content: body] ++ Map.to_list(attrs))
  end
end
