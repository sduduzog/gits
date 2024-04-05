defmodule Gits.Storefront do
  use Ash.Domain

  resources do
    resource Gits.Storefront.Customer
  end
end
