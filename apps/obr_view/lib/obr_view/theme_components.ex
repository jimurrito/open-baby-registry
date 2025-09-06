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
  Dynamic header element router
  """

  slot :inner_block, required: true

  attr :theme, :map, default: Themes.DefaultTheme
  attr :class, :string, default: ""

  def dyn_header(assigns) do
    {theme_mod, assigns} = Map.pop(assigns, :theme)
    apply(theme_mod, :dyn_header, [assigns])
  end

  #
  #
  @doc """
  Dynamic container element router
  """

  slot :inner_block, required: true

  attr :theme, :map, default: Themes.DefaultTheme
  attr :class, :string, default: ""

  def dyn_container(assigns) do
    {theme_mod, assigns} = Map.pop(assigns, :theme)
    apply(theme_mod, :dyn_container, [assigns])
  end
  
  
  
end
