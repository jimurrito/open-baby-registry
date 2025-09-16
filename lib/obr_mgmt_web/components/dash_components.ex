defmodule ObrMgmtWeb.DashComponents do
  @moduledoc """
  Rendering components for the Administrator Dash panel.
  """

  use Phoenix.Component

  #
  #
  @doc """
  Admin Dash root component
  """

  def dash(assigns) do
    ~H"""
    <div class="sticky top-10">
      <div class="dyn-container bg-gradient">
        <div class="dyn-title text-2xl underline">Admin Console</div>
      </div>

      <div class="dyn-container bg-gradient overflow-y-auto">
        <!--Add "h-[..px] if we add more options"-->
        <div class="dyn-title text-xl">Registry Settings</div>

        <form phx-submit="set-config">
          <!-- Baby Name -->
          <div>
            <label for="baby-name" class="font-bold">Your Baby's Name: </label>
            <input
              type="text"
              name="baby-name"
              value={@config.baby_name}
              class="mx-2 dyn-container p-1 my-2"
            />
          </div>
          <!-- Baby Gender -->
          <div>
            <label for="baby-gender"  class="font-bold">Gender: </label>
            <select name="baby-gender" class="mx-2 dyn-container my-2 p-1 w-[120px]">
              <%= for g <- ["Mystery", "Boy", "Girl"] do %>
                <%= if String.downcase(g) == @config.theme do %>
                  <option selected>{g}</option>
                <% else %>
                  <option>{g}</option>
                <% end %>
              <% end %>
            </select>
          </div>
          <!-- Diaper-Fund? -->
          <div>
            <label for="baby-dpf" class="font-bold my-2">Enable Diaper Fund?: </label>
            <input type="hidden" name="baby-dpf" value="off">
            <%= if @config.diaper_fund do %>
              <input checked name="baby-dpf" type="checkbox" class="drop-shadow-lg border-gray-400 border-2 mx-2 checked:bg-gray-600 hover:checked:bg-gray-600" />
            <% else %>
              <input name="baby-dpf" type="checkbox" class="drop-shadow-lg border-gray-400 border-2 mx-2 checked:bg-gray-600 hover:checked:bg-gray-600" />
            <% end %>
          </div>
          <!-- SAVE - MUST BE LAST -->
          <button class="dyn-button_n drop-shadow-lg border-gray-400 border-2 bg-gray-300 hover:bg-gray-400 hover:text-gray-500 my-3 mx-[200px]">
            Save
          </button>
        </form>
      </div>
      <!-- Registry item adding -->
      <div class="dyn-container bg-gradient">
        <div class="dyn-title text-xl">Add an item</div>
      </div>
    </div>
    """
  end

  #
  #

  attr(:submit_name, :string, required: true)

  def cfg_option(assigns) do
    ~H"""
    <form phx-submit={@submit_name}>
      <label></label>
    </form>
    """
  end
end
