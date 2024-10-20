# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :spark,
  formatter: [
    remove_parens?: true,
    "Ash.Resource": [
      section_order: [
        :resource,
        :code_interface,
        :actions,
        :policies,
        :pub_sub,
        :preparations,
        :changes,
        :validations,
        :multitenancy,
        :attributes,
        :relationships,
        :calculations,
        :aggregates,
        :identities
      ]
    ],
    "Ash.Domain": [section_order: [:resources, :policies, :authorization, :domain, :execution]]
  ]

config :gits,
  ash_domains: [Gits.Auth, Gits.Dashboard, Gits.Storefront, Gits.Admissions, Gits.Support],
  ecto_repos: [Gits.Repo]

config :ash, :utc_datetime_type, :datetime

config :ash, :compatible_foreign_key_types, [
  {Ash.Type.Integer, Ash.Type.UUID}
]

config :gits, time_zone: "Africa/Johannesburg"

# config :ash, :policies, show_policy_breakdowns?: true

# config :ash, :policies, log_policy_breakdowns: :error

# config :ash, :policies, log_successful_policy_breakdowns: :debug

config :gits, Oban,
  engine: Oban.Engines.Basic,
  queues: [default: 1, mailers: 1],
  repo: Gits.Repo

# plugins: [{Oban.Plugins.Cron, crontab: [{"* * * * *", Gits.Workers.SweepWaitlist}]}]

config :fun_with_flags, :cache, enabled: false, ttl: 120
config :fun_with_flags, :persistence, adapter: FunWithFlags.Store.Persistent.Ecto, repo: Gits.Repo

# Configures the endpoint
config :gits, GitsWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: GitsWeb.ErrorHTML, json: GitsWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Gits.PubSub,
  live_view: [signing_salt: "mAny0gpU"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :gits, Gits.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  gits: [
    args:
      ~w(js/app.js --bundle --target=es6 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  gits: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
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
