defmodule Gits.Repo do
  use AshPostgres.Repo,
    otp_app: :gits

  def installed_extensions do
    ["uuid-ossp", "citext"]
  end
end
