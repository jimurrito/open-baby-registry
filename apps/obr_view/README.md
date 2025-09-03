# ObrView

OBR View is a module that holds the themes and common rendering logic for the web pages.

## How to implement in an OBR OTP app

```elixir
# Add to mix.exs

def deps do
  [
    {:obr_view, in_umbrella: true},
  ]
end
```


# Modules

## `theme.ex`
A behavior used to implement themes using common callbacks.


## `theme_mapping.ex`
Simple module containing a function called `resolve/1` that is used to resolve the friendly theme atom to the module name.


## `theme_components.ex`
Phoenix components that are used to render the themes dynamically.

Relies on the `@theme` assign to determine the theme data to use.


# Themes

| Theme Atom | Friendly Name   | Module                        |
| ---------- | --------------- | ----------------------------- |
| `:default` | "Default-Theme" | `ObrView.Themes.DefaultTheme` |


