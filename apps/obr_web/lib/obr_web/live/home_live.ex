defmodule ObrWeb.HomeLive do
  @moduledoc false
  #
  #
  use ObrWeb, :live_view

  alias Phoenix.LiveView.AsyncResult
  alias Phoenix.LiveView.JS
  alias Obr.Auditor
  alias Obr.ConfigLoader, as: CF

  #
  #
  @impl true
  def mount(_params, _session, socket) do
    # Load default config
    config = CF.get_config()
    # Subscribe to Core table updates
    _ = Obr.Core.subscribe()

    {
      :ok,
      #
      socket
      #
      |> assign(:config, config)
      |> assign(:items, AsyncResult.loading())
      |> assign_async(:items, fn ->
        {:ok, %{items: Obr.fetch_all()}}
      end)
    }
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
          "auditor_id" => auditor_id,
          "ip" => ip
        },
        socket
      ) do
    # VERBOSE
    IO.inspect(%{
      "item_id" => item_id,
      "auditor_id" => auditor_id,
      "ip" => ip
    })

    # Set change to mnesia
    :ok = Obr.mark_purchased(item_id)
    # Send update to Auditor
    :ok = Auditor.track_purchase(ip, auditor_id, item_id)
    #
    {:noreply, socket}
  end

  #
  #
  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="text-4xl font-bold text-purple-800 drop-shadow-lg text-center">Baby registry</div>
      <div class="text-2xl font-bold text-purple-800 drop-shadow-lg text-center">for</div>
      <div class="text-2xl font-bold text-purple-800 drop-shadow-lg text-center">
        {@config.baby_name}
      </div>

      <hr class="my-10" />

      <div>
        <.con_list {assigns} />
      </div>

      <hr class="my-10" />

      <div>
        <.con_donations {assigns} />
      </div>
    </div>
    """
  end

  #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #
  # Constructors
  #

  #
  #
  @doc """
  Constructs the list of registry items
  """

  attr(:items, :list, required: true)

  def con_list(assigns) do
    ~H"""
    <.async_result :let={items} assign={@items}>
      <:loading>Loading board...</:loading>
      <:failed :let={_failure}>There was an error loading records.</:failed>
      <div class="my-4">
        <%= for {_tb, id, name, price, purchased?, store, url, ext, _created_on, _last_change} <- items do %>
          <div class={"grid grid-cols-[150px_1fr_150px] gap-2 items-start rounded-md drop-shadow-lg p-4 bg-white border-4 border-purple-300 my-4 #{is_purchased?(purchased?)}"}>
            <!---->
            <div class="justify-center">
              <a href={"id://#{id}"} class="font-bold">ⓘ</a>
              <div></div>
              <a class="font-bold text-xl underline" href={url}>{truncate(name)}</a>
              <div class="my-3 font-bold text-xl text-green-700">$ {Decimal.to_string(price)}</div>
              <div class="flex">Bought from: <.con_bought_from {%{store: store}} /></div>
              <.con_purchased? {%{id: id, purchased?: purchased?}} />
            </div>
            <!---->
            <div class=""></div>
            <!---->
            <div class="mx-auto">
              <a href={url}>
                <img
                  src={Map.get(ext, :img, "/images/shopping_cart.png")}
                  alt="Shopping cart"
                  class="w-[150px] h-[150px] object-contain opacity-100"
                />
              </a>
            </div>
            <!---->
            <.con_purchase_modal {%{id: id, name: name, audit_meta: @audit_meta}} />
          </div>
        <% end %>
      </div>
    </.async_result>
    """
  end

  #
  #
  @doc """
  Constructs `Bought From:` data

  # Options:

      :amz
      :target
      :walmart
      "other"

  """
  def con_bought_from(assigns) do
    # Get data from fake assigns
    Map.get(assigns, :store)
    |> case do
      #
      #
      :amz ->
        ~H"""
        <a href="https://a.co">
          <img src="/images/amz_logo.png" alt="AMZ Logo" class="w-[46px] h-[28px] object-contain" />
        </a>
        """

      #
      #
      :target ->
        ~H"""
        <a href="https://target.com">
          <img src="/images/target_logo.png" alt="target Logo" class="w-[46px] h-[28px] object-contain" />
        </a>
        """

      #
      #
      :walmart ->
        ~H"""
        <a href="https://walmart.com">
          <img
            src="/images/walmart_logo_2.png"
            alt="walmart Logo"
            class="w-[46px] h-[28px] object-contain"
          />
        </a>
        """

      #
      #
      _ ->
        ~H"""
        <div class="font-bold">
          {assigns.store}
        </div>
        """
    end
  end

  #
  #
  @doc """
  Constructs state for when item is purchased
  """
  def con_purchased?(assigns) do
    Map.get(assigns, :purchased?)
    |> if do
      ~H"""
      <div class="font-bold text-green-700">
        Purchased!
      </div>
      """
    else
      ~H"""
      <div class="font-bold text-red-700">
        Still needed!
      </div>
      <div>
        <button
          phx-click={JS.show(to: "#confirm-purchase#{assigns.id}", transition: "fade-in")}
          class="mt-3 bg-purple-600 hover:bg-purple-300 text-white font-semibold py-1 px-2 rounded shadow text-center"
        >
          I bought this!
        </button>
      </div>
      """
    end
  end

  #
  #
  def con_purchase_modal(assigns) do
    ~H"""
    <!---->
    <div
      id={"confirm-purchase#{assigns.id}"}
      class="hidden fixed inset-0 bg-black bg-opacity-50 flex justify-center items-center"
    >
      <div class="bg-white p-4 rounded shadow-lg">
        <h2 class="font-bold">Confirm Purchase</h2>
        <p class="my-2">Are you sure you purchased this?</p>
        <div class="flex">
          <form phx-submit="confirmed-purchase">
            <input class="hidden" type="text" name="item_id" value={assigns.id} />
            <input class="hidden" type="text" name="auditor_id" value={assigns.audit_meta.auditor_id} />
            <input class="hidden" type="text" name="ip" value={assigns.audit_meta.ip} />
            <.button
              phx-click={JS.hide(to: "#confirm-purchase#{assigns.id}", transition: "fade-out")}
              class="bg-green-600"
            >
              Yes
            </.button>
          </form>
          <.button
            phx-click={JS.hide(to: "#confirm-purchase#{assigns.id}", transition: "fade-out")}
            class="bg-red-600 mx-2"
          >
            No
          </.button>
        </div>
      </div>
    </div>
    """
  end

  #
  #
  def con_donations(assigns) do
    ~H"""
    <div class="text-center">
      <b>Not seeing anything you like?</b> Feel free to contribute our <i>Diaper Fund</i> below!
    </div>
    <div class="flex">
      <!--Cash App-->
      <a
        class="rounded-md drop-shadow-lg p-4 bg-white border-4 border-purple-300 my-4 mx-auto"
        href="https://cash.app/$butterscotchboiz"
      >
        <img
          src="/images/cash_app_qr.png"
          alt="cash_app_qr"
          class="w-[275px] h-[350px] object-contain"
        />
      </a>
    </div>
    """
  end

  #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #
  # Internal functions
  #

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
  @doc """
  Determines if a block should be available
  """
  def is_purchased?(true) do
    "opacity-70 pointer-events-none"
  end

  def is_purchased?(_) do
    ""
  end

  #
  #
  @doc """
  truncate long names
  """
  def truncate(long_string, char_limit \\ 20) do
    if String.length(long_string) > char_limit do
      "#{String.split_at(long_string, 20) |> elem(0)}.."
    else
      long_string
    end
  end

  #
  #
end
