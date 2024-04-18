defmodule ArangodbTest.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ArangodbTestWeb.Telemetry,
      # Start the Ecto repository
      ArangodbTest.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: ArangodbTest.PubSub},
      # Start Finch
      {Finch, name: ArangodbTest.Finch},
      # Start the Endpoint (http/https)
      ArangodbTestWeb.Endpoint
      # Start a worker by calling: ArangodbTest.Worker.start_link(arg)
      # {ArangodbTest.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ArangodbTest.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ArangodbTestWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
