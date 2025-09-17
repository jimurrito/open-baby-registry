defmodule Obr.Core do
  @moduledoc """
  Backend core.
  """
  require Decimal
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
    |> IO.inspect()

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
    price = Decimal.new(price)
    # write to table
    write(
      {CoreTable, UUID.uuid4(), name, price, false, store, url, ext, DateTime.now!("Etc/UTC"),
       DateTime.now!("Etc/UTC")}
    )
  end

  #
  #
  @doc """
  Fetches all records

  ## Record schema

      {CoreTable, binary(), binary(), Decimal.t(), boolean(), atom(), binary(), map(), DateTime.t(), DateTime.t()}

      {
      CoreTable,
      "e8c94dfd-46c8-49ad-9916-3b86488af61b",  1
      "PS5",  2
      Decimal.new("500.00"),   3
      false,   4
      :walmart,  5
      "https://www.walmart.com/ip/PlayStation-5-Digital-Console-Slim/5113183757?classType=REGULAR&athbdg=L1200",  6
      %{
        img: "https://i5.walmartimages.com/seo/PlayStation-5-Digital-Console-Slim_330f0b1b-c9b6-4d17-8875-f35fea51bdfd.587fde46f23ab38eb3197552e46f5305.jpeg"
      }, 7
      ~U[2025-09-16 17:03:33.824858Z], 8
      ~U[2025-09-16 17:03:33.824872Z] 9
      },

  """
  @spec fetch_all() :: [record()]
  def fetch_all() do
    :mnesia.dirty_select(CoreTable, [
      {{:"$1", :"$2", :"$3", :"$4", :"$5", :"$6", :"$7", :"$8", :"$9", :"$10"}, [],
       [
         %{
           id: :"$2",
           name: :"$3",
           price: :"$4",
           purchased?: :"$5",
           store: :"$6",
           url: :"$7",
           ext: :"$8",
           created_at: :"$9",
           updated_at: :"$10"
         }
       ]}
    ])
  end

  #
  #
  @doc """
  Converts an Mnesia record to a map
  """
  def to_map({_tb, id, name, price, purchased?, store, url, ext, created_at, updated_at}) do
    %{
      id: id,
      name: name,
      price: price,
      purchased?: purchased?,
      store: store,
      url: url,
      ext: ext,
      created_at: created_at,
      updated_at: updated_at
    }
  end

  #
  #
  @doc """
  Converts map back to record.
  """
  def from_map(%{
        id: id,
        name: name,
        price: price,
        purchased?: purchased?,
        store: store,
        url: url,
        ext: ext,
        created_at: created_at,
        updated_at: updated_at
      }) do
    #
    price = if Decimal.is_decimal(price), do: price, else: Decimal.new(price)
    store = if is_atom(store), do: store, else: String.to_atom(store)
    created_at = DateTime.from_iso8601(created_at) |> elem(1)
    updated_at = DateTime.from_iso8601(updated_at) |> elem(1)
    #
    {CoreTable, id, name, price, purchased?, store, url, ext, created_at, updated_at}
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
