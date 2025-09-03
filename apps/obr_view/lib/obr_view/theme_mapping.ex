defmodule ObrView.ThemeMapping do
  @moduledoc"""
  Function to map the theme atom to the module name.
  """

  alias ObrView.Themes


  def resolve(theme_atom) do
    theme_atom
    |> case  do
      :default -> Themes.DefaultTheme
    end

  end



end
