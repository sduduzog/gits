defmodule GitsWeb.Exceptions.NotFound do
  defexception [:message, plug_status: 404]
end
