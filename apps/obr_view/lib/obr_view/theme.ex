defmodule ObrView.Theme do
  @moduledoc """
  Macro to create OBR themes.
  """

  #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #
  # Callbacks
  #
  
  #
  @doc """
  Theme Atomic name.
  """
  @callback atom_name() :: atom()

  #
  @doc """
  Theme friendly name.
  """
  @callback friendly_name() :: binary()

  #
  @doc """
  Theme description.
  """
  @callback description() :: binary()
  
  #
  @doc """
  Dynamic header text.
  """
  @callback dyn_header(assigns :: map()) :: any()
  
  #
  @doc """
  Dynamic currency display.
  """
  @callback dyn_currency(assigns :: map()) :: any()
  
  #
  @doc """
  Dynamic container.
  """
  @callback dyn_container(assigns :: map()) :: any()

  #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #
  # `use` macro
  #

  #
  #
  defmacro __using__(_opts) do
    quote do
      @behaviour ObrView.Theme
      use Phoenix.Component
    end
  end

  #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #
  # Public API tools
  #

  





end
