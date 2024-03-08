defmodule Gits.Events do
  use Ash.Api

  resources do
    resource Gits.Events.Event
  end
end
