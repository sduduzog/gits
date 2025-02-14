defmodule Gits.Repo do
  use AshPostgres.Repo,
    otp_app: :gits

  def installed_extensions do
    ["ash-functions", "citext"]
  end

  def min_pg_version do
    %Version{major: 16, minor: 0, patch: 0}
  end
end
