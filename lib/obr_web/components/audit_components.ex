defmodule ObrWeb.AuditComponents do
  @moduledoc """
  Render components to help facilitate the auditing functions within `Obr.Auditor`.
  """

  use Phoenix.Component

  #
  #
  @doc """
  Audit payload for HTML Forms.
  """
  
  attr :audit_meta, :map, required: true
  
  def audit_payload(assigns) do
    ~H"""
    <div>
      <input class="hidden" type="text" name="audit_id" value={@audit_meta.audit_id} />
      <input class="hidden" type="text" name="ip" value={@audit_meta.ip} />
    </div>
    """
  end
end
