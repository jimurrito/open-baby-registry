defmodule ObrMgmtWeb.DashComponents do
  @moduledoc """
  Rendering components for the Administrator Dash panel.
  """
  
  use Phoenix.Component
  #import ObrWeb.CommonComponents
  
  #
  #
  @doc """
  
  """
  
  def dash(assigns) do
    ~H"""
    <div class="">
      <div class={"drop-shadow-lg text-center font-bold text-purple-800 text-2xl"}>Admin Console</div>   
    </div>
    """
  end
  
  
  
end