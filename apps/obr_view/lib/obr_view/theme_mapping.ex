defmodule ObrView.ThemeMapping do
  @moduledoc"""
  Function to map the theme atom to the module name.
  """

  alias ObrView.Themes

  
  
  #
  # 
  @doc """
  Resolves the Theme module name from the atom name.
  """
  def resolve(theme_atom) when is_atom(theme_atom) do
    theme_atom
    |> case  do
      :default -> Themes.DefaultTheme
    end
  end
  
  def resolve(theme_atom) when is_binary(theme_atom) do
    theme_atom
    |> String.to_atom()
    |> resolve()
  end
  
  
  
  
end
