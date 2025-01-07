defmodule Gits.Support do
  alias __MODULE__.{Admin, Job}
  use Ash.Domain

  resources do
    resource Admin
    resource Job
  end
end
