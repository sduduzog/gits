defmodule Gits.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :gits

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    domains()
    |> Enum.flat_map(fn domain ->
      domain
      |> Ash.Domain.Info.resources()
      |> Enum.map(&AshPostgres.DataLayer.Info.repo/1)
    end)
    |> Enum.uniq()
  end

  defp domains do
    Application.fetch_env!(@app, :ash_domains)
  end

  defp load_app do
    Application.load(@app)
  end
end
