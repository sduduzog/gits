defmodule Gits.Storefront do
  use Ash.Domain

  alias __MODULE__.{Order}

  resources do
    resource Order
  end
end
