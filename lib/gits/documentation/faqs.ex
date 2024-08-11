defmodule Gits.Documentation.Faqs do
  alias Gits.Documentation.Faq

  use NimblePublisher,
    build: Faq,
    from: Application.app_dir(:gits, "priv/faqs/**/*.md"),
    as: :faqs

  def all_faqs, do: @faqs
end
