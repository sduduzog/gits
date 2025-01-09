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

host = env!("PHX_HOST", :string)

config :gits, host: host

config :gits, tz: env!("TZ")

config :gits, :basic_auth,
  username: env!("BASIC_AUTH_USERNAME"),
  password: env!("BASIC_AUTH_PASSWORD")

config :gits, :google,
  client_id: env!("GOOGLE_CLIENT_ID"),
  client_secret: env!("GOOGLE_CLIENT_SECRET"),
  redirect_uri: env!("GOOGLE_REDIRECT_URI")

config :gits, :google_api_options,
  base_url: "https://places.googleapis.com",
  headers: ["X-Goog-Api-Key": env!("GOOGLE_MAPS_API_KEY")]

paystack_secret_key = env!("PAYSTACK_SECRET_KEY")

config :gits, :paystack_api_options,
  base_url: "https://api.paystack.co",
  auth: {:bearer, paystack_secret_key}

config :ex_aws,
  access_key_id: env!("AWS_S3_ACCESS_KEY_ID"),
  secret_access_key: env!("AWS_S3_SECRET_ACCESS_KEY"),
  region: env!("AWS_S3_REGION")

config :ex_aws, :s3,
  scheme: env!("AWS_S3_SCHEME"),
  host: env!("AWS_S3_HOST"),
  port: env!("AWS_S3_PORT", :integer)

config :gits, :bucket_name, env!("AWS_S3_BUCKET_NAME")

config :logger, level: env!("LOG_LEVEL", :atom, :debug)

config :gits, :paystack, secret_key: paystack_secret_key

if config_env() == :prod do
  database_url = env!("DATABASE_URL")

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :gits, Gits.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  secret_key_base = env!("SECRET_KEY_BASE", :string)

  port = env!("PORT", :integer, 4000)

  config :gits, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :gits, GitsWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  config :phoenix_turnstile,
    site_key: env!("TURNSTILE_SITE_KEY"),
    secret_key: env!("TURNSTILE_SECRET_KEY")

  config :gits, Gits.Mailer,
    adapter: Swoosh.Adapters.Brevo,
    api_key: env!("BREVO_API_KEY", :string)

  config :gits, :paystack, callback_url_base: "https://#{host}"
end
