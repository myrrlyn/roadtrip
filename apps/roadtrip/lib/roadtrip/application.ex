defmodule Roadtrip.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Roadtrip.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Roadtrip.PubSub}
      # Start a worker by calling: Roadtrip.Worker.start_link(arg)
      # {Roadtrip.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Roadtrip.Supervisor)
  end
end
