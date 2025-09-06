defmodule ObrMgmtWeb.Router do
  use ObrMgmtWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ObrMgmtWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug ObrWeb.Audit
  end

  # pipeline :api do
  #  plug :accepts, ["json"]
  # end

  live_session :default, on_mount: ObrWeb.Audit do
    scope "/", ObrMgmtWeb do
      pipe_through :browser
      live "/", HomeLive
    end
  end
end
