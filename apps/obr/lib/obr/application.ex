defmodule Obr.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {DNSCluster, query: Application.get_env(:obr, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Obr.PubSub}
      # Start a worker by calling: Obr.Worker.start_link(arg)
      # {Obr.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Obr.Supervisor)
  end
end
