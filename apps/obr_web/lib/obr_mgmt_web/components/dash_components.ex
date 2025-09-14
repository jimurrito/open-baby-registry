defmodule ObrMgmtWeb.DashComponents do
  @moduledoc """
  Rendering components for the Administrator Dash panel.
  """
  
  use Phoenix.Component
  import ObrWeb.CommonComponents
  
  #
  #
  @doc """
  
  """
  
  def dash(assigns) do
    ~H"""
    <div class="">
      <.title text_size="text-2xl" >Admin Console</.title>
    
    </div>
    
    """
  end
  
  
  
end