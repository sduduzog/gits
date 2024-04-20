defmodule GitsWeb.PageHTML do
  use GitsWeb, :html
  use PhoenixHTMLHelpers

  def get_listing_image(account_id, event_id) do
    Gits.Bucket.get_listing_image_path(account_id, event_id)
  end

  embed_templates "page_html/*"
end
