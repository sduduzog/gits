defmodule Gits.Support do
  use Ash.Domain

  resources do
    resource Gits.Support.Role
  end
end
