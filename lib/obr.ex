defmodule Obr do
  @moduledoc """
  Public API for backend.
  """

  alias Obr.Core, as: ObrCore

  #
  #
  @doc """
  Dumps auditor stats to the console.
  """
  @spec audit_info() :: :ok
  def audit_info() do
    Obr.Auditor.info()
  end

  #
  #
  @doc """
  Mark an item as purchased. Requires the UUID thats hidden on each page.
  """
  @spec mark_purchased(binary()) :: :ok
  def mark_purchased(id) do
    fn ->
      [{tb, id, name, price, _purchased?, store, url, ext, created_on, _lc}] =
        :mnesia.wread({CoreTable, id})

      :mnesia.write(
        {tb, id, name, price, true, store, url, ext, created_on, DateTime.now!("Etc/UTC")}
      )
    end
    |> :mnesia.transaction()
    |> elem(1)
  end

  #
  #
  @doc """
  Mark an item as not purchased. Requires the UUID thats hidden on each page.
  """
  @spec mark_not_purchased(binary()) :: :ok
  def mark_not_purchased(id) do
    fn ->
      [{tb, id, name, price, _purchased?, store, url, ext, created_on, _lc}] =
        :mnesia.wread({CoreTable, id})

      :mnesia.write(
        {tb, id, name, price, false, store, url, ext, created_on, DateTime.now!("Etc/UTC")}
      )
    end
    |> :mnesia.transaction()
    |> elem(1)
  end

  #
  #
  @doc """
  Create a new item record
  """
  @spec new(binary(), binary(), atom(), binary(), map()) :: :ok
  def new(name, price, store, url, ext \\ %{}) do
    ObrCore.new(name, price, store, url, ext)
  end

  #
  #
  @doc """
  Fetches all records.
  """
  @spec fetch_all() :: [tuple()]
  def fetch_all() do
    ObrCore.fetch_all()
  end

  #
  #
  @doc """
  Deletes a specific item by its `:id`.
  """
  @spec delete(binary()) :: :ok
  def delete(id) do
    ObrCore.delete(id)
  end

  #
  #
  @doc """
  Updates the item image for an item.
  """
  @spec update_thumb(binary(), binary()) :: :ok
  def update_thumb(id, new_image_url) do
    fn ->
      [{tb, id, name, price, purchased?, store, url, ext, created_on, _lc}] =
        :mnesia.wread({CoreTable, id})

      # Add new img URL to `ext`
      ext = Map.put(ext, :img, new_image_url)

      :mnesia.write(
        {tb, id, name, price, purchased?, store, url, ext, created_on, DateTime.now!("Etc/UTC")}
      )
    end
    |> :mnesia.transaction()
    |> elem(1)
  end

  #
  #
end
