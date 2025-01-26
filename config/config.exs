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
    Gits.Storefront,
    Gits.Support,
    Gits.Bucket
  ],
  ecto_repos: [Gits.Repo]

config :ash, :utc_datetime_type, :datetime

config :ash, :policies, show_policy_breakdowns?: true
config :ash, :policies, log_policy_breakdowns: :error

config :ash, :compatible_foreign_key_types, [
  {Ash.Type.Integer, Ash.Type.UUID}
]

config :gits, :presigned_url_options,
  virtual_host: true,
  bucket_as_host: true

config :gits, Oban,
  engine: Oban.Engines.Basic,
  queues: [default: 1],
  repo: Gits.Repo,
  plugins: [{Oban.Plugins.Pruner, max_age: 60 * 60 * 24 * 7}]

config :nanoid,
  size: 12,
  alphabet: "0123456789abcdefghijklmnopqrstuvwxyz"

config :gits, GitsWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: GitsWeb.ErrorHTML, json: GitsWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Gits.PubSub,
  live_view: [signing_salt: "mAny0gpU"]

config :gits, Gits.Mailer, adapter: Swoosh.Adapters.Local

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
