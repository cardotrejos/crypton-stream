defmodule CryptoStream.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CryptoStreamWeb.Telemetry,
      CryptoStream.Repo,
      {DNSCluster, query: Application.get_env(:crypto_stream, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CryptoStream.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: CryptoStream.Finch},
      # Start a worker by calling: CryptoStream.Worker.start_link(arg)
      # {CryptoStream.Worker, arg},
      # Start to serve requests, typically the last entry
      CryptoStreamWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CryptoStream.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CryptoStreamWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
