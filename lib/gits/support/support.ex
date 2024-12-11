defmodule Gits.Support do
  alias __MODULE__.{Admin}
  use Ash.Domain

  resources do
    resource Admin
  end
end
