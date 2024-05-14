defmodule Gits.Dashboard.Actions.ReadGoogleAddress do
  use Ash.Resource.ManualRead

  def read(_query, _data_layer_query, _opts, _context) do
    {:ok, %{}}
  end
end
