defmodule Gits.Documentation.Articles do
  alias GitsWeb.Exceptions.NotFound
  alias Gits.Documentation.Article

  use NimblePublisher,
    build: Article,
    from: Application.app_dir(:gits, "priv/articles/**/*.md"),
    as: :articles

  def all_articles, do: @articles

  def get_article_by_id!(id) do
    Enum.find(all_articles(), &(&1.id == id)) ||
      raise NotFound, "article with id=#{id} not found"
  end
end
