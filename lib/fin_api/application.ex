defmodule FinApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      FinApi.Repo,
      # Start the Telemetry supervisor
      FinApiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: FinApi.PubSub},
      # Start the Endpoint (http/https)
      FinApiWeb.Endpoint,
      # Start a worker by calling: FinApi.Worker.start_link(arg)
      # {FinApi.Worker, arg}
      FinApi.Node,
      FinApi.Indexer,
      FinApi.Invalidator
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FinApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FinApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
