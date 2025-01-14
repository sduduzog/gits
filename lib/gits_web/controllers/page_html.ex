defmodule GitsWeb.PageHTML do
  use GitsWeb, :html
  import GitsWeb.StoryblockComponents

  embed_templates "page_html/*"

  def blok_faq(assigns) do
    ~H"""
    <div>faq</div>
    """
  end
end
