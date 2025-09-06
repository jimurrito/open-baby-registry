defmodule ObrView.Themes.DefaultTheme do
  @moduledoc """
  Default theme used by OBR
  """

  #use ObrView.Theme
  
  #@impl true
  def atom_name(), do: :default

  #@impl true
  def friendly_name(), do: "Default-Theme"

  #@impl true
  def description(), do: "Default theme used by OBR."
  
  #
  #
  
  #slot :inner_block, required: true
  #attr :class, :string, default: ""
  
  #@impl true
  #def dyn_header(assigns) do
  #  ~H"""
  #   <div class={"font-bold drop-shadow-lg text-center text-4xl text-purple-800 #{@class}"}>
  #    {render_slot(@inner_block)}
  #  </div>
  #  """
  #end

end
