defmodule Gits.Admissions do
  use Ash.Domain

  resources do
    resource Gits.Admissions.Attendee
  end
end