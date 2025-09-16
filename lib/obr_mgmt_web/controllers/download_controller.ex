defmodule ObrMgmtWeb.DownloadController do
  @moduledoc """
  Endpoint controller for file downloading.
  """

  use ObrMgmtWeb, :controller

  alias Obr.ConfigLoader, as: CF

  #
  #
  @doc """
  Preps the backup data, and pushes into a file.
  Pushes file created to client.
  """
  def backup(conn, _params) do
    # make backup state
    backup =
      %{
        config: CF.get_config(),
        core: Obr.fetch_all(),
        audit: Obr.Auditor.fetch_all()
      }
      |> Jason.encode!(pretty: true)

    {:ok,
     send_download(conn, {:binary, backup},
       filename: "obr-backup-#{DateTime.now!("Etc/UTC")}.json",
       content_type: "application/json"
     )}
  end
end
