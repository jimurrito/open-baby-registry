defmodule ObrWeb.RegistyComponents do
  @moduledoc """
  Divs that handle specific parts of rendering the web page.
  """

  use Phoenix.Component
  import ObrWeb.CoreComponents

  import ObrWeb.CommonComponents
  import ObrWeb.ComponentTools
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
    </.async_result>
    """
  end

  #
  #
  @doc """
  Renders the registry item container. Only renders a single item. Should be used within a list.
  """

  attr :id, :string, required: true
  attr :name, :string, required: true
  attr :price, :string, required: true
  attr :purchased?, :boolean, required: true
  attr :store, :string, required: true
  attr :url, :string, required: true
  attr :ext, :map, default: %{}

  def registry_item(assigns) do
    ~H"""
    <.container class={"grid grid-cols-[150px_1fr_150px] gap-2 #{make_unavailable(@purchased?)}"}>
      <!--Left-hand side-->
      <div class="justify-center">
        <!--Item Title + Link-->
        <a class="font-bold text-xl underline" href={@url}>{truncate(@name)}</a>
        <!--Dollar Amount-->
        <div class="my-3 font-bold text-xl text-green-700">$ {Decimal.to_string(@price)}</div>
        <!--Bought from `x`-->
        <div class="flex">Bought from: <.bought_from store={@store} /></div>
        <!--Purchase status-->
        <.con_purchased? {%{id: @id, purchased?: @purchased?}} />
      </div>
      <!--Divider-->
      <div></div>
      <!--Right-hand side-->
      <div class="mx-auto">
        <.img_link
          url={@url}
          src={Map.get(@ext, :img, "/images/shopping_cart.png")}
          alt="Shopping cart"
        />
      </div>
      <!--Purchase button + Modal pop-out-->
      <.con_purchase_modal {%{id: @id, name: @name, audit_meta: @audit_meta}} />
      <!---->
    </.container>
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

  attr :store, :atom, required: true

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
        <.img_link
          size="w-[46px] h-[28px]"
          class=""
          url={@store_data.u}
          src={@store_data.s}
          alt={@store_data.a}
        />
        """
    end
  end

  #
  #  NEW ^^^
  #
  #
  #
  #  OLD VVV
  #

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
      <.img_link
        url="https://cash.app/$butterscotchboiz"
        src="/images/cash_app_qr.png"
        alt="cash_app_qr"
        size="w-[275px] h-[350px]"
        class="rounded-md drop-shadow-lg p-4 bg-white border-4 border-purple-300 my-4 mx-auto"
      />
    </div>
    """
  end
end
