[
  import_deps: [
    :ecto,
    :ecto_sql,
    :phoenix,
    :ash,
    :ash_phoenix,
    :ash_postgres,
    :ash_authentication,
    :ash_authentication_phoenix,
    :ash_state_machine,
    :ash_archival
  ],
  subdirectories: ["priv/*/migrations"],
  plugins: [TailwindFormatter, Phoenix.LiveView.HTMLFormatter],
  inputs: ["*.{heex,eex,ex,exs}", "{config,lib,test}/**/*.{heex,ex,exs}", "priv/*/seeds.exs"]
]
