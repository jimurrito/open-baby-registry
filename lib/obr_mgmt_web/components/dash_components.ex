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
    <div class="sticky top-16">
      <div class="dyn-container p-3 bg-gradient overflow-y-auto">
        <!--Add "h-[..px] if we add more options"-->
        <div class="dyn-title text-xl">Registry Settings</div>

        <form phx-submit="set-config">
          <!-- Baby Name -->
          <div>
            <label for="baby-name" class="font-bold">Your Baby's Name: </label>
            <input
              required
              type="text"
              name="baby-name"
              value={@config.baby_name}
              class="mx-2 dyn-container p-1 my-1 w-half"
            />
          </div>
          <!-- Baby Gender -->
          <div>
            <label for="baby-gender" class="font-bold">Gender: </label>
            <select name="baby-gender" class="mx-2 dyn-container my-2 p-1 w-[120px]">
              <%= for g <- ["Mystery", "Boy", "Girl"] do %>
                <%= if String.downcase(g) == @config.theme do %>
                  <option selected>{g}</option>
                <% else %>
                  <option>{g}</option>
                <% end %>
              <% end %>
            </select>
            <label for="baby-gender" class="italic text-gray-600">Refresh to show new theme</label>
          </div>
          <!-- Diaper-Fund? -->
          <div class="pointer-events-none opacity-40">
            <label for="baby-dpf" class="font-bold my-2">Enable Diaper Fund?: </label>
            <input type="hidden" name="baby-dpf" value="off" />
            <%= if @config.diaper_fund do %>
              <input
                checked
                name="baby-dpf"
                type="checkbox"
                class="drop-shadow-lg border-gray-400 border-2 mx-2 checked:bg-gray-600 hover:checked:bg-gray-600"
              />
            <% else %>
              <input
                name="baby-dpf"
                type="checkbox"
                class="drop-shadow-lg border-gray-400 border-2 mx-2 checked:bg-gray-600 hover:checked:bg-gray-600"
              />
            <% end %>
          </div>
          <!-- SAVE - MUST BE LAST -->
          <button
            phx-disable-with="Saving..."
            class="dyn-button_n drop-shadow-lg border-gray-400 border-2 bg-gray-300 hover:bg-gray-400 hover:text-gray-500 my-3 mx-[200px]"
          >
            Save
          </button>
        </form>
      </div>
      <!-- Registry item adding -->
      <div class="dyn-container bg-gradient">
        <div class="dyn-title text-xl">Add an item</div>
        <form phx-submit="add-item">
          <!-- URL -->
          <div>
            <label for="item-url" class="font-bold">Item URL: </label>
            <br />
            <!-- Removed phx-change="item-url-parse" for now -->
            <textarea
              required
              name="item-url"
              class="dyn-container p-1 my-2 w-full max-h-20 overflow-y-auto"
            ></textarea>
          </div>
          <!-- Item Friendly name -->
          <div>
            <label for="item-name" class="font-bold">Item Display Name: </label>
            <input required name="item-name" class="dyn-container p-1 my-2 w-full" />
          </div>
          <!-- Store Type -->
          <div>
            <label for="item-store" class="font-bold">Bought from: </label>
            <select name="item-store" class="mx-2 dyn-container my-2 p-1 w-[120px]">
              <option value="amz">Amazon</option>
              <option value="walmart">Walmart</option>
              <option value="target">Target</option>
              <option value="other">Other</option>
            </select>
          </div>
          <!-- Price -->
          <div>
            <label for="item-cost" class="font-bold">Cost ($): </label>
            <input
              required
              name="item-cost"
              type="number"
              min="0"
              step="0.01"
              placeholder="0.00"
              class="mx-2 dyn-container my-2 p-1 w-[120px]"
            />
          </div>
          <!-- SAVE - MUST BE LAST -->
          <button
            phx-disable-with="Saving..."
            class="dyn-button_n drop-shadow-lg border-gray-400 border-2 bg-gray-300 hover:bg-gray-400 hover:text-gray-500 my-3 mx-[180px] w-[100px]"
          >
            Add Item
          </button>
        </form>
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
