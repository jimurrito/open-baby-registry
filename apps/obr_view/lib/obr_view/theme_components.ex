defmodule ObrView.ThemeComponents do
  @moduledoc """
  HTML components that have some tailwind CSS data reconfigured on them.
  Colors are pulled from the `@theme` assign and modules that use `ObrView.Theme`.
  """

  use Phoenix.Component
  alias ObrView.Themes

  #
  #
  @doc """
  Div that acts as a basic box to hold other elements.
  """

  slot :inner_block, required: true

  attr :theme, :map, default: Themes.DefaultTheme
  attr :class, :string, default: ""

  def dyn_container(assigns) do
    ~H"""
    <div class={"rounded-md drop-shadow-lg p-4 border-4 #{@theme.dyn_container()} #{@class}"}>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
