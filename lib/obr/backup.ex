defmodule Obr.Backup do
  @moduledoc """
  Handles backup and restore of core OBR databases.
  """

  alias Obr.ConfigLoader, as: CF
  alias Obr.Core
  #alias Obr.Auditor
  require Logger

  #
  #
  @doc """
  Generates a backup in JSON format
  """
  def generate() do
    %{
      config: CF.get_config(),
      core: Obr.fetch_all(),
      audit: Obr.Auditor.fetch_all()
    }
    |> Jason.encode!(pretty: true)
  end

  #
  #
  @doc """
  Restores system from the backup file.
  ALL CONFLICTING DATA WILL BE OVERWRITTEN BY THE BACKUP
  """
  def restore(%{
        config: config,
        core: core,
        audit: audit
      }) do
    # Sets config back to ETS and local config.json file
    :ok = CF.set_config(config)
    :ok = restore_core(core)
    :ok = restore_auditor(audit)
    :ok
  end

  #
  #
  # Restores core db from backup
  defp restore_core(backup) do
    backup
    |> Enum.each(fn item ->
      :ok =
        Core.from_map(item)
        |> Core.write()
    end)
  end

  #
  #
  # Restores core db from backup
  defp restore_auditor(_backup) do
    #backup
    #|> Enum.each(fn item ->
    #  :ok =
    #    Auditor.from_map(item)
    #    |> Auditor.write()
    #end)
    
    Logger.warning("Restoring Auditing data is currently not supported.")
    :ok
  end
end
