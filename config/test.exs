import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :gits, Gits.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "gits_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :gits, GitsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "0UXDIIqIDXpqAFu1zdaKcGE+WAq4zs6ODx40OnXKlt56KLstOQ7FraalRl586YLp",
  server: false

# In test we don't send emails.
config :gits, Gits.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :ash, :disable_async?, true
config :ash, :missed_notifications, :ignore

config :gits, Oban, testing: :inline

config :gits, :google_api_options, plug: {Req.Test, :google_api}

config :gits, :paystack_api_options, plug: {Req.Test, :paystack_api}
