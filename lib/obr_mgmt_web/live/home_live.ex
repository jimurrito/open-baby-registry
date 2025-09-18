defmodule ObrMgmtWeb.HomeLive do
  @moduledoc false
  #
  #
  use ObrMgmtWeb, :live_view

  alias Phoenix.LiveView.AsyncResult
  alias Obr.Auditor
  alias Obr.ConfigLoader, as: CF
  import ObrWeb.RegistyComponents
  import ObrMgmtWeb.DashComponents

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
    # Convert update to map
    update = Obr.Core.to_map(update)
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
    # Set change to mnesia
    :ok = Obr.mark_purchased(item_id)
    # Send update to Auditor
    :ok = Auditor.track_purchase(ip, audit_id, item_id)
    #
    {:noreply, socket}
  end

  #
  # handles config updates for the registry
  @impl true
  def handle_event(
        "set-config",
        %{
          "baby-dpf" => dpf?,
          "baby-gender" => gender,
          "baby-name" => name
        },
        socket
      ) do
    # dpf fix
    diaper_fund? = dpf? == "on"
    # gender to theme
    theme = if gender == "Mystery", do: "dark", else: String.downcase(gender)
    # get base config
    config =
      CF.get_config()
      # mod base
      |> Map.put(:theme, theme)
      |> Map.put(:baby_name, name)
      |> Map.put(:diaper_fund, diaper_fund?)

    # Set config
    :ok = CF.set_config(config)

    #
    socket =
      socket
      |> assign(:config, config)
      |> put_flash(:info, "Updated settings!")

    # Set to assigns
    {:noreply, socket}
  end

  #
  # handle adding an item
  @impl true
  def handle_event(
        "add-item",
        %{"item-cost" => cost, "item-name" => name, "item-store" => store, "item-url" => url},
        socket
      ) do
    #
    :ok = Obr.new(name, cost, String.to_atom(store), url)

    socket =
      socket
      |> put_flash(:info, "Saved item to registry!")

    #
    {:noreply, socket}
  end

  #
  #
  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex justify-end px-20 sticky top-12 my-2">
      <.link href="/adv" class="underline">Advanced settings</.link>
    </div>
    <div class="grid grid-cols-[672px_1fr_500px] gap-10 items-start mx-20">
      <.prod_page {assigns} />
      <div></div>
      <.dash {assigns} />
    </div>
    """
  end

  #
  #
  @doc """
  The Copy of the prod page within a container
  """

  attr(:config, :map, required: true)

  def prod_page(assigns) do
    ~H"""
    <div class="dyn-container border-15 p-10 bg-gradient">
      <div class="dyn-title text-5xl">Baby Registry</div>
      <div class="dyn-title text-3xl my-3">for</div>
      <div class="dyn-title text-4xl">{@config.baby_name}</div>
      <!---->
      <hr class="dyn-hr" />
      <!---->
      <.registry_item_list {assigns} />
      <!---->
      <hr class="dyn-hr" />
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
    list
    |> Enum.map(fn
      # Record matches the input
      record when record.id == input_record.id ->
        input_record

      # all else
      record ->
        record
    end)
  end

  #
  #
end
