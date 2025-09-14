import Config

#
#
# Mnesia config
config :mnesia,
  dir: ~c"./db"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :obr, ObrWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "nOW3gNIPRzl1qah9o0DX8g8fij1jxhTuVpkFLagGOnIdUbvpH9RSlxIy0sneEkk5",
  server: false

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :obr, ObrMgmtWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4402],
  secret_key_base: "nOW3gNIPRzl1qah9o0DX8g8fij1jxhTuVpkFLagGOnIdUbvpH9RSlxIy0sneEkk5",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
