# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :process_label, :pid, :module]


config :obr_web,
  generators: [context_app: :obr]


config :obr_mgmt_web,
  generators: [context_app: :obr]


# Configures the public endpoint
config :obr_web, ObrWeb.Endpoint,
  server: true,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ObrWeb.ErrorHTML, json: ObrWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Obr.PubSub,
  live_view: [signing_salt: "EAAQo9R/"]


# Configures the mgmt endpoint
config :obr_mgmt_web, ObrMgmtWeb.Endpoint,
  server: true,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ObrMgmtWeb.ErrorHTML, json: ObrMgmtWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Obr.PubSub,
  live_view: [signing_salt: "EAAQo9R/"]



# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  obr_web: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../apps/obr_web/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ],
  obr_mgmt_web: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../apps/obr_mgmt_web/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]


# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  obr_web: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../apps/obr_web/assets", __DIR__)
  ],
  obr_mgmt_web: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../apps/obr_mgmt_web/assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
