defmodule Gits.MixProject do
  use Mix.Project

  def project do
    [
      app: :gits,
      version: "0.1.0",
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Gits.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:ash_authentication_phoenix, "~> 2.0"},
      {:oban_web, "~> 2.0"},
      {:assent, "== 0.2.10"},
      {:premailex, "~> 0.3"},
      {:nanoid, "~> 2.0"},
      {:ash_slug, "~> 0.1"},
      {:nimble_totp, "~> 1.0"},
      {:nimble_publisher, "~> 1.0"},
      {:ash_paper_trail, "~> 0.1"},
      {:ash_state_machine, "~> 0.2"},
      {:phoenix_live_view, "~> 1.0"},
      {:phoenix, "~> 1.7"},
      {:ash, "~> 3.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_pubsub, "~> 2.1"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:ecto_psql_extras, "~> 0.6"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:floki, ">= 0.30.0"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:swoosh, "~> 1.16"},
      {:gen_smtp, "~> 1.2"},
      {:finch, "~> 0.18"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.2"},
      {:picosat_elixir, "~> 0.2.0"},
      {:ash_phoenix, "~> 2.0"},
      {:ash_postgres, "~> 2.0"},
      {:ash_authentication, "== 4.3.4"},
      {:ash_archival, "~> 1.0.3"},
      {:slugify, "~> 1.3"},
      {:eqrcode, "~> 0.1.10"},
      {:timex, "~> 3.7"},
      {:dotenvy, "~> 0.8.0"},
      {:req, "~> 0.4.0"},
      {:cachex, "~> 4.0"},
      {:image, "~> 0.44"},
      {:ex_aws, "~> 2.5"},
      {:ex_aws_s3, "~> 2.4"},
      {:hackney, "~> 1.20"},
      {:sweet_xml, "~> 0.7.4"},
      {:phoenix_seo, "~> 0.1.9"},
      {:oban, "~> 2.0"},
      {:mock, "~> 0.3.8", only: :test},
      {:power_assert, "~> 0.3.0", only: :test},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:igniter, "~> 0.5"},
      {:dialyxir, "~> 1.1", only: [:dev], runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ash.setup --quiet", "test"],
      "assets.setup": ["cmd --cd assets npm i"],
      "assets.build": ["cmd --cd assets npx vite build --config vite.config.ts"],
      "assets.deploy": [
        "cmd --cd assets npx vite build --mode production --config vite.config.ts",
        "phx.digest"
      ],
      "ash.setup": ["ash.setup", "run priv/repo/seeds.exs"]
    ]
  end
end
