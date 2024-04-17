defmodule GitsWeb.PageHTML do
  use GitsWeb, :html
  use PhoenixHTMLHelpers

  embed_templates "page_html/*"

  defp get_listing_image(account_id, event_id) do
    get_image(account_id, event_id, "listing")
  end

  defp get_feature_image(account_id, event_id) do
    get_image(account_id, event_id, "feature")
  end

  def get_image(account_id, event_id, type) do
    filename = "#{account_id}/#{event_id}/#{type}.jpg"

    ExAws.S3.head_object("gits", filename)
    |> ExAws.request()
    |> case do
      {:ok, _} -> "/bucket/#{filename}"
      _ -> "/images/placeholder.png"
    end
  end
end
