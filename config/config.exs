import Config

config :ash,
  include_embedded_source_by_default?: false,
  default_page_type: :keyset,
  policies: [no_filter_static_forbidden_reads?: false]

config :spark,
  formatter: [
    remove_parens?: true,
    "Ash.Resource": [
      section_order: [
        :postgres,
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
  ash_domains: [
    Gits.Accounts,
    Gits.Hosts,
    Gits.Storefront,
    Gits.Support
  ],
  ecto_repos: [Gits.Repo]

config :ash, :utc_datetime_type, :datetime

config :ash, :compatible_foreign_key_types, [
  {Ash.Type.Integer, Ash.Type.UUID}
]

config :gits, time_zone: "Africa/Johannesburg"

config :gits, :email, sender: {"GiTS", "localhost"}

# config :ash, :policies, show_policy_breakdowns?: true

# config :ash, :policies, log_policy_breakdowns: :error

# config :ash, :policies, log_successful_policy_breakdowns: :debug

config :gits, Oban,
  engine: Oban.Engines.Basic,
  queues: [default: 1],
  repo: Gits.Repo,
  plugins: [{Oban.Plugins.Pruner, max_age: 60 * 60 * 24 * 7}]

config :nanoid,
  size: 12,
  alphabet: "0123456789abcdefghijklmnopqrstuvwxyz"

# plugins: [{Oban.Plugins.Cron, crontab: [{"* * * * *", Gits.Workers.SweepWaitlist}]}]

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
  version: "0.24.0",
  gits: [
    args:
      ~w(js/app.js --bundle --target=esnext --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.13",
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
