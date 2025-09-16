defmodule ObrMgmtWeb.AdvConfigLive do
  @moduledoc false
  #
  #
  use ObrMgmtWeb, :live_view
  alias Obr.ConfigLoader, as: CF

  #
  #
  @impl true
  def mount(_params, _session, socket) do
    # Load default config
    config = CF.get_config()

    socket =
      socket
      |> assign(:config, config)

    {:ok, socket}
  end

  #
  #
  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex justify-left px-20 sticky top-5">
      <.link href="/" class="underline">{"← Back to Admin Console"}</.link>
    </div>

    <div class="dyn-container bg-gradient mx-20">
      <div class="dyn-title text-2xl">Advanced Settings</div>
      <hr class="dyn-hr" />
      <!-- Config blocks -->
      <div class="flex flex-wrap gap-4">
        <!-- backup and restore DB -->
        <div class="dyn-container dyn-bg w-[400px]">
          <div class="dyn-title text-xl">Backup/Restore</div>
          <hr class="dyn-hr border-1 my-3" />
          <!-- Download backup -->
            <.link class="dyn-button_n drop-shadow-lg border-gray-400 border-2 bg-gray-300 hover:bg-gray-400 hover:text-gray-500 my-3"
              href={~p"/download-backup"} target="_blank"
            >
              Download backup
            </.link>
          <!-- Upload backup -->

        </div>
        <!-- CSV Upload -->
        <div class="dyn-container dyn-bg w-[400px]">
          <div class="dyn-title text-xl">CSV File upload</div>
          <hr class="dyn-hr border-1 my-3" />
          <!--

          CONTENT

          -->
        </div>
      </div>
    </div>
    """
  end
end
