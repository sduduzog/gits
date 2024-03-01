defmodule Gits.Schema do
  use Absinthe.Schema

  @apis [Gits.Accounts]

  use AshGraphql, apis: @apis

  query do
  end

  mutation do
  end
end
