defmodule ObrWeb.Audit do
  @moduledoc """
  This is a plug that acts as an interface for `Obr.Auditor`
  """

  require Logger
  import Plug.Conn
  alias Plug.Conn
  alias Obr.Auditor

  #
  #
  @doc """
  Initial fn called on Plug execution. Input value will be ignored.
  """
  @spec init(default :: any()) :: default :: any()
  def init(default), do: default

  #
  #
  @doc """
  Logic called on Plug call.
  This allows access to the Plug Connection struct.
  Must use `Plug.Conn.put_session` or data will not be accessible in LiveView.
  """
  @spec call(Conn.t(), any()) :: Conn.t()
  def call(conn, _default) do
    # make session ID
    auditor_id = UUID.uuid4()
    client_ip = :inet.ntoa(conn.remote_ip) |> to_string()
    audit_meta = %{audit_id: auditor_id, ip: client_ip}
    # push connection info to Auditor
    :ok = Auditor.track_connection(client_ip, auditor_id)

    # Push audit_ID into the session
    conn = fetch_session(conn)
    conn = put_session(conn, :audit_meta, audit_meta)
    # Push to assigns
    conn = assign(conn, :audit_meta, audit_meta)
    #
    conn
  end

  #
  #
  @doc """
  Entry point for liveView. Called on each mount of a liveView connection.
  Only has access to LiveView data.
  This block pulls the AuditID from the session and push into assigns.
  """
  def on_mount(:default, _params, session, socket) do
    audit_meta = session |> Map.fetch!("audit_meta")
    {:cont, Phoenix.Component.assign(socket, :audit_meta, audit_meta)}
  end

  #
end
