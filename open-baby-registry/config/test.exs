import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :obr, ObrWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Xz6f6JtoJWoeDgWCm9HbD4Mmig045MLUNxJ2SKqGUifKShoBcnN4I/Qw47YcaZ80",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
