defmodule ObrWeb.CommonComponentsOld do
  @moduledoc """
  Common components to render the page and streamline the use of themes.
  """

  use Phoenix.Component

  #
  #
  @doc """
  Renders a <hr/> div with a predefined
  """

  attr :class, :string, default: ""

  def hr(assigns) do
    ~H"""
    <hr class={"my-10 drop-shadow-lg rounded-md border-2 border-purple-300 #{@class}"} />
    """
  end

  #
  #
  @doc """
  Renders a div that acts as the page header
  """

  slot :inner_block, required: true
  attr :class, :string, default: ""
  attr :text_size, :string, default: "text-4xl"

  def title(assigns) do
    ~H"""
    <div class={"drop-shadow-lg text-center font-bold text-purple-800 #{@text_size} #{@class}"}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  #
  #
  @doc """
  Renders a div that acts as the page header.
  """

  slot :inner_block, required: true
  attr :class, :string, default: ""

  def container(assigns) do
    ~H"""
    <div class={"my-4 p-4 drop-shadow-lg rounded-md border-4 items-start border-purple-300 #{@class}"}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  #
  #
  @doc """
  Renders an link element with an embedded image.
  """

  attr :size, :string, default: "w-[150px] h-[150px]"
  # Default should route back to self
  attr :url, :string, default: "/"
  attr :alt, :string, default: "Shopping cart"
  attr :src, :string, default: "/images/shopping_cart.png"
  attr :class, :string, default: ""
  attr :img_class, :string, default: ""

  def img_link(assigns) do
    ~H"""
    <a href={@url} class={@class}>
      <img src={@src} alt={@alt} class={"object-contain #{@size} #{@img_class}"} />
    </a>
    """
  end
end
