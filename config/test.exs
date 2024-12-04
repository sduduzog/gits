import Config

config :gits, Gits.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "gits_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

config :gits, GitsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "0UXDIIqIDXpqAFu1zdaKcGE+WAq4zs6ODx40OnXKlt56KLstOQ7FraalRl586YLp",
  server: false

config :gits, Gits.Mailer, adapter: Swoosh.Adapters.Test

config :swoosh, :api_client, false

config :logger, level: :warning

config :phoenix, :plug_init_mode, :runtime

config :ash, :disable_async?, true
config :ash, :missed_notifications, :ignore

config :gits, Oban, testing: :inline

config :gits, :google_api_options, plug: {Req.Test, :google_api}

config :gits, :paystack_api_options, plug: {Req.Test, :paystack_api}
