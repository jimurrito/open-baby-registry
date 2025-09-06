defmodule ObrMgmtWeb.HomeLive do
  @moduledoc false
  #
  #
  use ObrMgmtWeb, :live_view

  alias Phoenix.LiveView.AsyncResult
  alias Obr.Auditor
  alias Obr.ConfigLoader, as: CF
  import ObrWeb.CommonComponents
  import ObrWeb.RegistyComponents
  
  #
  #
  @impl true
  def mount(_params, _session, socket) do
    # Load default config
    config = CF.get_config()
    # Subscribe to Core table updates
    _ = Obr.Core.subscribe()

    socket =
      socket
      # |> assign(:theme, config.theme)
      # |> assign(:theme, "boy")
      |> assign(:config, config)
      |> assign(:items, AsyncResult.loading())
      |> assign_async(:items, fn ->
        {:ok, %{items: Obr.fetch_all()}}
      end)

    {:ok, socket}
  end

  #
  #
  # handles async responses
  @impl true
  def handle_async(assign, msg, socket) do
    result =
      msg
      |> case do
        # job finished successfully
        {:ok, assign_response} ->
          fetched = assign_response |> Map.get(assign)
          update(socket, assign, &AsyncResult.ok(&1, fetched))

        # failed to complete
        {:exit, reason} ->
          update(socket, assign, &AsyncResult.failed(&1, {:exit, reason}))
      end

    {:noreply, result}
  end

  #
  #
  # Updates page from Mnesia updates.
  @impl true
  def handle_info(
        {:mnesia_table_event, {_opt_type, update, _op_data}},
        socket
      ) do
    # Get table name from record update
    {:noreply, mnesia_update_list(socket, :items, update)}
  end

  #
  # handles button press actions for the purchase button
  @impl true
  def handle_event(
        "confirmed-purchase",
        %{
          "item_id" => item_id,
          "audit_id" => audit_id,
          "ip" => ip
        },
        socket
      ) do
    # VERBOSE
    IO.inspect(%{
      "item_id" => item_id,
      "audit_id" => audit_id,
      "ip" => ip
    })

    # Set change to mnesia
    :ok = Obr.mark_purchased(item_id)
    # Send update to Auditor
    :ok = Auditor.track_purchase(ip, audit_id, item_id)
    #
    {:noreply, socket}
  end

  #
  #
  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.title text_size="text-5xl">Baby Registry</.title>
      <.title text_size="text-3xl" class="my-3">for</.title>
      <.title text_size="text-4xl">{@config.baby_name}</.title>
      <!---->
      <.hr />
      <!---->
      <.registry_item_list {assigns} />
      <!---->
      <.hr />
      <!---->
      <.donation_panel {assigns} />
    </div>
    """
  end


  #
  #
  @doc """
  Mnesia updates for assigns. Updates the provided assign's list with the record provided.
  """
  def mnesia_update_list(socket, assign, record) do
    fnc = &AsyncResult.ok(&1, update_record_list(&1.result, record))
    update(socket, assign, fnc)
  end

  #
  #
  @doc """
  Updates an item in a list with the input one.
  The input record's key must match the key of the record in the list.
  If the record is not found in the list, nothing will change on the list.
  New records are not added. Only replaces existing records.
  """
  @spec update_record_list(list(tuple()), tuple()) :: list(tuple())
  def update_record_list(list, input_record) do
    input_key = input_record |> elem(1)

    list
    |> Enum.map(fn
      # Record matches the input
      record when elem(record, 1) == input_key ->
        input_record

      # all else
      record ->
        record
    end)
  end

  #
  #
end
