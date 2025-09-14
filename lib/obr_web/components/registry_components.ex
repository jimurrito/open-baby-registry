defmodule ObrWeb.RegistyComponents do
  @moduledoc """
  Divs that handle specific parts of rendering the web page.
  """

  use Phoenix.Component
  import ObrWeb.CoreComponents

  # import ObrWeb.CommonComponents
  import ObrWeb.ComponentTools
  import ObrWeb.AuditComponents
  # alias Phoenix.LiveView.AsyncResult
  alias Phoenix.LiveView.JS

  #
  #
  @doc """
  Constructs the list of registry items
  """

  attr(:items, :list, required: true)

  def registry_item_list(assigns) do
    ~H"""
    <.async_result :let={items} assign={@items}>
      <:loading>Loading board...</:loading>
      <:failed :let={_failure}>There was an error loading records.</:failed>
      <!---->
      <div class="my-4">
        <%= for {_tb, id, name, price, purchased?, store, url, ext, _created_on, _last_change} <- items do %>
          <.registry_item
            id={id}
            name={name}
            price={price}
            purchased?={purchased?}
            store={store}
            url={url}
            ext={ext}
            {assigns}
          />
        <% end %>
      </div>
      <!---->
    </.async_result>
    """
  end

  #
  #
  @doc """
  Renders the registry item container. Only renders a single item. Should be used within a list.
  """

  attr(:id, :string, required: true)
  attr(:name, :string, required: true)
  attr(:price, :string, required: true)
  attr(:purchased?, :boolean, required: true)
  attr(:store, :string, required: true)
  attr(:url, :string, required: true)
  attr(:ext, :map, default: %{})

  def registry_item(assigns) do
    ~H"""
    <div class={"grid grid-cols-[150px_1fr_150px] gap-2 dyn-container dyn-bg #{make_unavailable(@purchased?)}"}>
      <!--Left-hand side-->
      <div class="justify-center">
        <!--Item Title + Link-->
        <a class="font-bold text-xl underline" href={@url}>{truncate(@name)}</a>
        <!--Dollar Amount-->
        <div class="my-3 font-bold text-2xl text-green-700">${Decimal.to_string(@price)}</div>
        <!--Bought from `x`-->
        <div class="flex">Bought from: <.bought_from {assigns} /></div>
        <!--Purchase status + Purchase button-->
        <.purchase_status {assigns} />
      </div>
      <!--Divider-->
      <div></div>
      <!--Right-hand side-->
      <div class="mx-auto">
        <a href={@url}>
          <img
            src={Map.get(@ext, :img, "/images/shopping_cart.png")}
            alt={@name}
            class="object-contain w-[150px] h-[150px]"
          />
        </a>
      </div>
      <!--Modal pop-out (hidden by default)-->
      <.purchase_modal {assigns} />
      <!---->
    </div>
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

  attr(:store, :atom, required: true)

  def bought_from(assigns) do
    # Get data from assigns
    Map.get(assigns, :store)
    |> case do
      :amz -> %{u: "https://a.co", s: "/images/amz_logo.png", a: "Amazon Logo"}
      :target -> %{u: "https://target.com", s: "/images/target_logo.png", a: "Target Logo"}
      :walmart -> %{u: "https://walmart.com", s: "/images/walmart_logo_2.png", a: "Walmart Logo"}
      rest -> {:other, rest}
    end
    |> case do
      #
      {:other, _rest} ->
        ~H"""
        <div class="font-bold">
          {@store}
        </div>
        """

      #
      data ->
        # Push store data to assigns
        assigns = Map.put(assigns, :store_data, data)

        ~H"""
        <a href={@store_data.u}>
          <img src={@store_data.s} alt={@store_data.a} class="object-contain w-[46px] h-[28px]" />
        </a>
        """
    end
  end

  #
  #
  @doc """
  Constructs state for when item is purchased.
  If item is unpurchased, the `I bought this!` button will be rendered.
  """

  attr(:purchased, :boolean, required: true)

  def purchase_status(assigns) do
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
        <.i_bought_this_button {assigns} />
      </div>
      """
    end
  end

  #
  #
  @doc """
  Renders the `I bought this` button.
  When togged, the div rendered by `purchase_modal` will become visable.
  """

  attr(:id, :string, required: true)

  def i_bought_this_button(assigns) do
    ~H"""
    <.button
      phx-click={JS.show(to: "#confirm-purchase#{@id}", transition: "fade-in")}
      class="mt-3 dyn-button"
    >
      I bought this!
    </.button>
    """
  end

  #
  #
  @doc """
  Purchase confirmation modal dialog. Hidden by default.
  """

  attr(:id, :string, required: true)
  attr(:audit_meta, :map, required: true)

  def purchase_modal(assigns) do
    ~H"""
    <!-- Gray-out layer -->
    <div
      id={"confirm-purchase#{@id}"}
      class="hidden fixed inset-0 bg-black bg-opacity-50 flex justify-center items-center"
    >
      <!-- Modal box -->
      <div class="bg-white p-4 rounded shadow-lg">
        <h2 class="font-bold">Confirm Purchase</h2>
        <p class="my-2">Are you sure you purchased this?</p>
        <div class="flex my-2">
          <form phx-submit="confirmed-purchase">
            <!--Item ID payload-->
            <input class="hidden" type="text" name="item_id" value={@id} />
            <!--Obr.Auditor tracking payload.-->
            <.audit_payload {assigns} />
            <!--Yes is inside the form so it submits the confirmation-->
            <button
              phx-click={JS.hide(to: "#confirm-purchase#{@id}", transition: "fade-out")}
              class="dyn-button_n bg-green-600 hover:bg-green-400"
            >
              Yes
            </button>
          </form>
          <!--No is outside the form so clicking it loses focus-->
          <button
            phx-click={JS.hide(to: "#confirm-purchase#{@id}", transition: "fade-out")}
            class="dyn-button_n bg-red-600 hover:bg-red-400 mx-2"
          >
            No
          </button>
        </div>
      </div>
    </div>
    """
  end

  #
  #
  def donation_panel(assigns) do
    ~H"""
    <div class="text-center">
      <b>Not seeing anything you like?</b> Feel free to contribute our <i>Diaper Fund</i> below!
    </div>
    <div class="flex">
      <!--Cash App-->
      <a href="https://www.youtube.com/watch?v=dQw4w9WgXcQ" class="dyn-container bg-white mx-auto">
        <img
          src="https://upload.wikimedia.org/wikipedia/commons/2/2f/Rickrolling_QR_code.png"
          alt="test_qrcode"
          class="object-contain w-[275px] h-[350px]"
        />
      </a>
    </div>
    """
  end
end
