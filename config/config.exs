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

config :obr,
  config_path: System.get_env("CONFIG_PATH", "./"),
  baby_name: "Baby Name",
  theme: :boy,
  diaper_fund: false,
  due_date:
    System.get_env("DUE_DATE", DateTime.now!("Etc/UTC") |> DateTime.add(6570, :hour) |> to_string)

config :obr,
  generators: [timestamp_type: :utc_datetime]

# Configures the public endpoint
config :obr, ObrWeb.Endpoint,
  server: true,
  url: [host: "localhost"],
  check_origin: ["http://localhost:4000"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ObrWeb.ErrorHTML, json: ObrWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Obr.PubSub,
  live_view: [signing_salt: "EAAQo9R/"]

# Configures the mgmt endpoint
config :obr, ObrMgmtWeb.Endpoint,
  server: true,
  url: [host: "localhost"],
  check_origin: ["http://localhost:4400"],
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
  obr: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  obr: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
