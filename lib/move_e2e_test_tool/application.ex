defmodule MoveE2eTestTool.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      MoveE2eTestToolWeb.Telemetry,
      # Start the Ecto repository
      MoveE2eTestTool.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: MoveE2eTestTool.PubSub},
      # Start Finch
      {Finch, name: MoveE2eTestTool.Finch},
      # Start the Endpoint (http/https)
      MoveE2eTestToolWeb.Endpoint
      # Start a worker by calling: MoveE2eTestTool.Worker.start_link(arg)
      # {MoveE2eTestTool.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MoveE2eTestTool.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MoveE2eTestToolWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
