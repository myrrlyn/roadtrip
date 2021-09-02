defmodule RoadtripWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      RoadtripWeb.Telemetry,
      # Start the Endpoint (http/https)
      RoadtripWeb.Endpoint
      # Start a worker by calling: RoadtripWeb.Worker.start_link(arg)
      # {RoadtripWeb.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RoadtripWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RoadtripWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
