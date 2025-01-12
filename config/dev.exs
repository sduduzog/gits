import Config

config :gits, Gits.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "gits_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 1

config :gits, GitsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: false,
  secret_key_base: "LM4JibxEdu9bKBXtor7YzZQlHpjn5655cfndsFI7HAUQ92uvj0q7wsB0+VHS4eZV",
  watchers: [
    npx: [
      "vite",
      "build",
      "--mode",
      "development",
      "--watch",
      "--config",
      "vite.config.ts",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

config :gits, GitsWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"priv/pages/*/*.(md)$",
      ~r"priv/faqs/*/*.(md)$",
      ~r"lib/gits_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

config :gits, dev_routes: true

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view, :debug_heex_annotations, true

config :swoosh, :api_client, false

config :ash, :pub_sub, debug?: true

config :gits, :presigned_url_options,
  virtual_host: false,
  bucket_as_host: false

config :gits, :workers,
  order_created_schedule_seconds: 60,
  order_created_snooze_seconds: 60

config :gits, Gits.Mailer,
  host: "http://localhost",
  domain: "localhost"

config :gits, :paystack, callback_url_base: "http://localhost:4000"
