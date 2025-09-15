defmodule Obr.Auditor do
  @moduledoc """
  Auditor for write actions and connections to the server.
  When a user/agent connects for the first time, their IP will be cached and a session ID will be created for this interaction.
  """

  require Logger
  use GenServer

  #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #
  # Types
  #

  #
  #
  @typedoc """
  Mnesia record struct
  """
  @type record() ::
          {
            table :: AuditorTable,
            ip :: binary(),
            connection_count :: non_neg_integer(),
            connection :: connection_record(),
            actions :: action_record(),
            created_on :: DateTime.t(),
            last_change :: DateTime.t()
          }

  #
  #
  @typedoc """
  Generic connection metadata struct
  """
  @type connection_record() :: {auditor_id :: binary(), time :: DateTime.t()}

  #
  #
  @typedoc """
  Metadata struct for actions performed on the page
  """
  @type action_record() :: {auditor_id :: binary(), item_id :: binary(), time :: DateTime.t()}

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
  def init(_init_arg) do
    Logger.info(status: :startup)
    # Start table - ignore result as it may already be created
      :mnesia.create_table(
        AuditorTable,
        attributes: [
          :ip,
          :connection_count,
          :connections,
          :actions,
          :created_on,
          :last_change
        ],
        index: [],
        type: :set,
        disc_copies: [node()]
      )
      |> IO.inspect

    Logger.info(status: :startup_complete)
    {:ok, :ok}
  end

  #
  # Handles casts for new connections
  @impl true
  def handle_cast({:new_connection, {ip, auditor_id}}, :ok) do
    # Create connection record
    now! = DateTime.now!("Etc/UTC")
    conn_rec = {auditor_id, now!}

    #
    :ok =
      fn ->
        # Check if the Ip is already recorded
        :mnesia.wread({AuditorTable, ip})
        |> case do
          #
          # record is found -> add new connection to record
          [{AuditorTable, ^ip, _count, conns, actions, co, _lc}] ->
            # New connection list
            conns = [conn_rec | conns]
            {AuditorTable, ip, length(conns), conns, actions, co, now!}

          #
          # Not found -> create record
          [] ->
            {AuditorTable, ip, 1, [conn_rec], [], now!, now!}
        end
        |> :mnesia.write()
      end
      |> :mnesia.transaction()
      |> elem(1)

    #
    {:noreply, :ok}
  end

  #
  # Handles casts for new connections
  @impl true
  def handle_cast({:purchase, {ip, auditor_id, item_id}}, :ok) do
    # Create connection record
    now! = DateTime.now!("Etc/UTC")
    action_rec = {auditor_id, now!, item_id}

    #
    :ok =
      fn ->
        # Check if the Ip is already recorded
        :mnesia.wread({AuditorTable, ip})
        |> case do
          #
          # record is found -> add new action to record
          [{AuditorTable, ^ip, _count, conns, actions, co, _lc}] ->
            #
            {AuditorTable, ip, length(conns), conns, [action_rec | actions], co, now!}

          #
          # Not found -> create record with conn+action records
          [] ->
            {AuditorTable, ip, 1, [{auditor_id, now!}], [action_rec], now!, now!}
        end
        |> :mnesia.write()
      end
      |> :mnesia.transaction()
      |> elem(1)

    #
    {:noreply, :ok}
  end

  #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #
  # Public API functions
  #

  #
  #
  @doc """
  Tracks a new connection for a client.
  """
  def track_connection(ip, auditor_id) do
    GenServer.cast(__MODULE__, {:new_connection, {ip, auditor_id}})
  end

  #
  #
  @doc """
  Tracks an action performed by an agent.
  """
  def track_purchase(ip, auditor_id, item_id) do
    GenServer.cast(__MODULE__, {:purchase, {ip, auditor_id, item_id}})
  end

  #
  #
  @doc """
  Displays stats to the console.
  """
  def info() do
    """

    |---------------------|
    |  Auditor statistics |
    |---------------------|
    #{render_stats()}

    """
    |> IO.puts()
  end

  #
  #
  defp render_stats() do
    :mnesia.dirty_select(AuditorTable, [
      {:mnesia.table_info(AuditorTable, :wild_pattern), [], [:"$_"]}
    ])
    |> Enum.map(fn {_tb, ip, con_count, conns, _actions, _co, _lc} ->
      # create header
      header = "|\n|\n|\n|-[ip: #{ip}, connections: #{con_count}]\n|   |\n"
      # Create connection rows.
      body =
        Enum.map(conns, fn {auditor_id, time} ->
          "|   |-[time: #{time}, audit_id: #{auditor_id}]"
        end)
        |> Enum.join("\n")

      header <> body <> "\n|"
    end)
    |> Enum.join("\n")
  end

  #
  #
end
