defmodule Obr.ConfigLoader do
  @moduledoc """
  Handles configurations for the web server (Not the OTP server).

  # Public API

  - `get_config/0` | Retrieves the site config from ETS.
  - `set_config/1` | Input config is set to ETS and JSON File

  This setup allows the config to be changes either at runtime or via a docker compose change.

  """

  require Logger
  use GenServer
  alias Jason

  #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #
  # GenServer callback functions
  #

  #
  #
  @doc """
  Supervisor Entry point.
  """
  @spec start_link(any()) :: GenServer.on_start()
  def start_link(init_args \\ []) do
    GenServer.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  #
  #
  @impl true
  def init(_init_args) do
    #
    # Load default config
    config = get_env()
    #
    # Attempt to read the config file
    config =
      load_json_conf(config.config_path)
      |> case do
        {:error, error} ->
          Logger.error([job: :reading_json_config, error: error])
          :ok = set_json_conf(config.config_path, config)
          config

        {:ok, config} ->
          config
      end

    :obr_config = :ets.new(:obr_config, [:set, :protected, :named_table])
    _ = :ets.insert(:obr_config, {:config, config})

    {:ok, config.config_path}
  end

  #
  #
  # Update write back
  @impl true
  def handle_cast({:update, config}, path) do
    _ = :ets.insert(:obr_config, {:config, config})
    :ok = set_json_conf(path, config)
    {:noreply, path}
  end

  #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #
  # Public API Functions
  #

  #
  #
  @doc """
  Retrieves the site config from ETS
  """
  @spec get_config() :: map()
  def get_config() do
    [config: config] = :ets.lookup(:obr_config, :config)
    config
  end

  #
  #
  @doc """
  Alerts `Obr.ConfigLoader` so it can write back to the JSON file
  """
  @spec set_config(map()) :: :ok
  def set_config(config) do
    GenServer.cast(__MODULE__, {:update, config})
  end


  #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #
  # Internal Functions
  #

  #
  # Pull config from App Env
  @spec get_env() :: map()
  defp get_env() do
    Application.get_all_env(:obr) |> Enum.into(%{})
  end

  #
  #
  # load JSON config
  defp load_json_conf(path) do
    File.read("#{path}/config.json")
    |> case do
      # file exists
      {:ok, data} -> {:ok, Jason.decode!(data, keys: :atoms)}
      # file does not exist, or other error
      error -> error
    end
  end

  #
  #
  # Set state to JSON config file
  defp set_json_conf(path, data) when is_map(data), do: set_json_conf(path, Jason.encode!(data))

  defp set_json_conf(path, data) when is_binary(data) do
    File.write!("#{path}/config.json", data)
  end
end
