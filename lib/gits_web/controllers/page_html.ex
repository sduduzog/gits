defmodule GitsWeb.PageHTML do
  use GitsWeb, :html
  import GitsWeb.StoryblockComponents

  embed_templates "page_html/*"
end
