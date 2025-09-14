defmodule ObrWeb.ComponentTools do
  @moduledoc """
    Generic functions to help sculpt data prior to being rendered.
  """

  #
  #
  @doc """
  Truncate strings longer then `x` amount. Default amount is `20` characters.
  """
  @spec truncate(binary(), integer()) :: binary()
  def truncate(long_string, char_limit \\ 30) do
    if String.length(long_string) > char_limit do
      String.slice(long_string, 0..char_limit) <> "..."
    else
      long_string
    end
  end

  #
  #
  @doc """
  Determines if a block should be available or not.
  If `true` is provided, class data will be provided that makes 
  the element opacity 70% and disables pointer events.
  """
  @spec make_unavailable(boolean()) :: binary()
  def make_unavailable(true), do: "pointer-events-none"
  def make_unavailable(_), do: ""

  #
  #
end
