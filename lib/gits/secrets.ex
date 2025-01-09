defmodule Gits.Secrets do
  use AshAuthentication.Secret
  alias Gits.Accounts.User

  def secret_for([:authentication, :tokens, :signing_secret], User, _) do
    case Application.fetch_env(:gits, GitsWeb.Endpoint) do
      {:ok, endpoint_config} -> Keyword.fetch(endpoint_config, :secret_key_base)
      :error -> :error
    end
  end

  def secret_for([:authentication, :strategies, strategy, key], User, _) do
    Application.get_env(:gits, strategy, [])
    |> Keyword.fetch(key)
  end
end
