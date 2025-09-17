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
      |> allow_upload(:restore_file, accept: ~w(.json), max_entries: 1)

    {:ok, socket}
  end

  #
  #
  # handles consuming the backup file once uploaded
  @impl true
  def handle_event("backup-restore", _params, socket) do
    :ok =
      socket
      |> consume_uploaded_entries(:restore_file, fn %{path: path}, _entry ->
        {:ok,
         File.read!(path)
         |> Jason.decode(keys: :atoms)}
      end)
      |> case do
        # Content provided
        [ok: backup_contents] ->
          # Push state into backup module
          Obr.Backup.restore(backup_contents)

        # No content
        [] ->
          :ok
      end

    {:noreply, socket}
  end

  #
  #
  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
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
          <div class="my-3">
            <div class="dyn-title text-xl">Backup/Restore</div>
            <hr class="dyn-hr border-1 my-3" />
            <!-- Download backup -->
            <div class="my-2 text-center font-semibold">Download current Database/Config</div>
            <div class="flex">
              <a
                class="dyn-button_n drop-shadow-lg border-gray-400 border-2 bg-gray-300 hover:bg-gray-400 hover:text-gray-500 mx-auto"
                href={~p"/download-backup"}
                target="_blank"
                phx-disable-with="Preparing..."
              >
                Download Backup
              </a>
            </div>
          </div>
          <hr class="dyn-hr my-6" />
          <!-- Upload backup -->
          <form phx-submit="backup-restore" phx-change="validate" class="text-center">
            <label for="restore-file" class="my-2 font-semibold">Upload backup</label>
            <.live_file_input
              upload={@uploads.restore_file}
              class="dyn-button_n w-full drop-shadow-lg border-gray-400 border-2 bg-gray-300 hover:bg-gray-400 hover:text-gray-500"
            />
            <div class="flex">
              <button
                phx-disable-with="Uploading..."
                class="dyn-button_n drop-shadow-lg border-gray-400 border-2 bg-gray-300 hover:bg-gray-400 hover:text-gray-500 my-3 mx-auto"
              >
                Restore
              </button>
            </div>
          </form>
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
