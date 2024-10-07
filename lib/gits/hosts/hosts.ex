defmodule Gits.Hosts do
  use Ash.Domain

  alias __MODULE__.Host

  resources do
    resource Host
  end
end
