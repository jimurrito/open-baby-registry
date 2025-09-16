defmodule Obr.Core do
  @moduledoc """
  Backend core.
  """
  alias Obr.ThumbFetch

  require Logger
  use GenServer

  #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #
  # Types
  #
  # [:id, :name, :price, :purchased? :store, :url, :ext, :created_on, :last_change],
  @type record() ::
          {CoreTable, binary(), binary(), Decimal.t(), boolean(), atom(), binary(), map(),
           DateTime.t(), DateTime.t()}

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
        CoreTable,
        attributes: [
          :id,
          :name,
          :price,
          :purchased?,
          :store,
          :url,
          :ext,
          :created_on,
          :last_change
        ],
        index: [],
        type: :ordered_set,
        # ram_copies: [node()]
        disc_copies: [node()]
      )
      |> IO.inspect

    Logger.info(status: :startup_complete)
    {:ok, :ok}
  end

  #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #
  # Public API functions
  #

  #
  #
  @doc """
  Subscribes to the CoreTable mnesia table.
  """
  @spec subscribe(type :: :simple | :detailed) :: {:ok, node()} | {:error, reason :: term()}
  def subscribe(type \\ :simple) do
    :mnesia.subscribe({:table, CoreTable, type})
  end

  #
  #
  @doc """
  Creates a new record.

  ## Record schema

      {CoreTable, binary(), binary(), Decimal.t(), boolean(), atom(), binary(), map(), DateTime.t(), DateTime.t()}

  """
  @spec new(binary(), binary(), atom(), binary(), map()) :: :ok
  def new(name, price, store, url, ext \\ %{}) do
    # Attempt to resolve the URL for the header image
    ext = Map.put(ext, :img, ThumbFetch.fetch(url, store))
    price = Decimal.new(price) |> Decimal.round(2)
    # write to table
    write(
      {CoreTable, UUID.uuid4(), name, price, false, store, url, ext,
       DateTime.now!("Etc/UTC"), DateTime.now!("Etc/UTC")}
    )
  end

  #
  #
  @doc """
  Fetches all records

  ## Record schema

      {CoreTable, binary(), binary(), Decimal.t(), boolean(), atom(), binary(), map(), DateTime.t(), DateTime.t()}

  """
  @spec fetch_all() :: [record()]
  def fetch_all() do
    :mnesia.dirty_select(CoreTable, [{:mnesia.table_info(CoreTable, :wild_pattern), [], [:"$_"]}])
  end

  #
  #
  @doc """
  Writes an update for a given record, based on its key.

  ## Record schema

      {CoreTable, binary(), binary(), Decimal.t(), boolean(), atom(), binary(), map(), DateTime.t(), DateTime.t()}

  """
  @spec write(record()) :: :ok
  def write(new_record) do
    fn ->
      :mnesia.write(new_record)
    end
    |> :mnesia.transaction()
    |> elem(1)
  end

  #
  #
  @doc """
  Deletes a given record, based on its key.

  ## Record schema

      {CoreTable, binary(), binary(), Decimal.t(), boolean(), atom(), binary(), map(), DateTime.t(), DateTime.t()}

  """
  @spec delete(binary()) :: :ok
  def delete(record_key) do
    fn ->
      :mnesia.delete({CoreTable, record_key})
    end
    |> :mnesia.transaction()
    |> elem(1)
  end

  #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #
  # Internal functions
  #

  #
  #
end
