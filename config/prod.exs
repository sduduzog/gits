import Config

config :gits, GitsWeb.Endpoint, cache_static_manifest: "priv/static/cache_manifest.json"

config :swoosh, api_client: Swoosh.ApiClient.Req

config :swoosh, local: false

config :gits, :presigned_url_options,
  virtual_host: true,
  bucket_as_host: true,
  expires_in: 900

config :gits, :workers,
  reclaim_open_basket_timeout: 1_200,
  reclaim_payment_started_basket_timeout: 1_800

config :sentry,
  dsn:
    "https://ff8905f3ab19071b0df977da3a43d54e@o4506665217032192.ingest.us.sentry.io/4507737254723584",
  environment_name: Mix.env(),
  enable_source_code_context: true,
  root_source_code_paths: [File.cwd!()],
  integrations: [
    oban: [
      capture_errors: true
    ]
  ]
