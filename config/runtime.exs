import Config
import Dotenvy

if System.get_env("PHX_SERVER") do
  config :gits, GitsWeb.Endpoint, server: true
end

config_dir_prefix =
  System.fetch_env("RELEASE_ROOT")
  |> case do
    :error ->
      ""

    {:ok, value} ->
      IO.puts("Loading dotenv files from #{value}")
      "#{value}/"
  end

source!(["#{config_dir_prefix}.env", System.get_env()])

config :gits, :google_api_options,
  base_url: "https://places.googleapis.com",
  headers: ["X-Goog-Api-Key": env!("GOOGLE_MAPS_API_KEY")]

config :gits, :paystack_api_options,
  base_url: "https://api.paystack.co",
  auth: {:bearer, env!("PAYSTACK_SECRET_KEY")}

config :ex_aws,
  access_key_id: env!("AWS_ACCESS_KEY_ID"),
  secret_access_key: env!("AWS_SECRET_ACCESS_KEY"),
  region: env!("AWS_REGION")

config :ex_aws, :s3,
  scheme: env!("AWS_S3_SCHEME"),
  host: env!("AWS_S3_HOST"),
  port: env!("AWS_S3_PORT", :integer)

config :gits, :bucket_name, env!("BUCKET_NAME")

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :gits, Gits.Repo,
    url: database_url,
    pool_size: env!("POOL_SIZE", :integer, 2),
    socket_options: maybe_ipv6

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = env!("PHX_HOST", :string)
  port = env!("PORT", :integer, 4000)

  config :gits, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :gits, GitsWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  config :gits, :base_url, "https://#{host}"

  config :phoenix_turnstile,
    site_key: env!("TURNSTILE_SITE_KEY"),
    secret_key: env!("TURNSTILE_SECRET_KEY")

  domain = env!("MAILGUN_DOMAIN", :string)
  api_key = env!("MAILGUN_API_KEY", :string)

  config :gits, Gits.Mailer,
    adapter: Swoosh.Adapters.Mailgun,
    api_key: api_key,
    domain: domain,
    base_url: "https://api.eu.mailgun.net/v3"

  config :gits, :sender_email, "hey@#{domain}"
end
