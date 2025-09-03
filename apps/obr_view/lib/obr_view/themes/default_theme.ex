defmodule ObrView.Themes.DefaultTheme do
  @moduledoc """
  Default theme used by OBR
  """

  use ObrView.Theme


  @impl true
  def friendly_name(), do: "Default-Theme"

  @impl true
  def description(), do: "Default theme used by OBR."

  @impl true
  def text_color(), do: ""

  @impl true
  def dollar_color(), do: ""

  @impl true
  def background(), do: ""

  @impl true
  def border(), do: ""

  @impl true
  def dyn_container(), do: ""

  @impl true
  def gradient(), do: ""


end
