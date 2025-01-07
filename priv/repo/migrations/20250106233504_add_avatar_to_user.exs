defmodule Gits.Repo.Migrations.AddAvatarToUser do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:users) do
      add :avatar, :text
    end
  end

  def down do
    alter table(:users) do
      remove :avatar
    end
  end
end
