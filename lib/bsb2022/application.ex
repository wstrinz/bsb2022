defmodule Bsb2022.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Bsb2022.Repo,
      # Start the Telemetry supervisor
      Bsb2022Web.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Bsb2022.PubSub},
      # Start the Endpoint (http/https)
      Bsb2022Web.Endpoint
      # Start a worker by calling: Bsb2022.Worker.start_link(arg)
      # {Bsb2022.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bsb2022.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Bsb2022Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
