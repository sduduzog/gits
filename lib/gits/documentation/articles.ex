defmodule Gits.Documentation.Articles do
  alias Gits.Documentation.Article

  use NimblePublisher,
    build: Article,
    from: Application.app_dir(:gits, "priv/articles/**/*.md"),
    as: :articles

  def all_articles, do: @articles
end
