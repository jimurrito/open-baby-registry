defmodule Obr.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      #
      # Backend
      Obr.Core,
      Obr.Auditor,
      Obr.ConfigLoader,
      # Start the Finch HTTP client
      {Finch, name: Obr.Finch},

      #
      # PHX dependencies
      {DNSCluster, query: Application.get_env(:obr, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Obr.PubSub}
      # Start a worker by calling: Obr.Worker.start_link(arg)
      # {Obr.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Obr.Supervisor)
  end

  #
  # whenever the application is updated.
  @impl true
  def config_change(_changed, _new, _removed) do
    :ok
  end

end
