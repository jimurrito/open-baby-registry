defmodule ObrMgmtWeb.DownloadController do
  @moduledoc """
  Endpoint controller for file downloading.
  """

  use ObrMgmtWeb, :controller

  alias Obr.Backup

  #
  #
  @doc """
  Preps the backup data, and pushes into a file.
  Pushes file created to client.
  """
  def backup(conn, _params) do
    {:ok,
     send_download(conn, {:binary, Backup.generate()},
       filename: "obr-backup-#{DateTime.now!("Etc/UTC")}.json",
       content_type: "application/json"
     )}
  end
end
