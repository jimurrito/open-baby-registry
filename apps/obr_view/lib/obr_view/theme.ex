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
  Text color.
  """
  @callback text_color() :: binary()

  #
  @doc """
  Color used for currency.
  """
  @callback dollar_color() :: binary()

  #
  @doc """
  Page background. (Typically used in `app.html.heex`)
  """
  @callback background() :: binary()

  #
  @doc """
  Generic element border color
  """
  @callback border() :: binary()

  #
  @doc """
  `dyn_container` background & border color.
  """
  @callback dyn_container() :: binary()

  #
  @doc"""
  FOR TESTING UNTIL CONFIRM BEHAVIOUR

  Example: `linear-gradient(270deg, #fbcfe8, #f9a8d4, #d8b4fe)`

  https://tailwindcss.com/docs/background-image#setting-gradient-color-stops
  """
  @callback gradient() :: binary()

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
    end
  end

  #
  # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
  #
  # Public API tools
  #

  





end
