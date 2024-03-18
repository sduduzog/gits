defmodule GitsWeb.Exceptions.AccountNotFoundError do
  defexception [:message, plug_status: 404]
end
