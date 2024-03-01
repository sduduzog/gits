defmodule Gits.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GitsWeb.Telemetry,
      Gits.Repo,
      {DNSCluster, query: Application.get_env(:gits, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Gits.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Gits.Finch},
      # Start a worker by calling: Gits.Worker.start_link(arg)
      # {Gits.Worker, arg},
      # Start to serve requests, typically the last entry
      GitsWeb.Endpoint,
      {AshAuthentication.Supervisor, otp_app: :gits}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gits.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GitsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
