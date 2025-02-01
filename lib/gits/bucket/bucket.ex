defmodule Gits.Bucket do
  use Ash.Domain
  alias __MODULE__.Image

  resources do
    resource Image
  end
end
