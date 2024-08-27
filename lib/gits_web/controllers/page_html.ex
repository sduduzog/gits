defmodule GitsWeb.PageHTML do
  use GitsWeb, :html
  use PhoenixHTMLHelpers

  alias Gits.Storefront.Event

  def get_listing_image(account_id, event_id) do
    Gits.Bucket.get_listing_image_path(account_id, event_id)
  end

  defp resolve_min_price_label(price) do
    if Decimal.eq?(price, 0) do
      "FREE"
    else
      "R#{price |> Gits.Currency.format()}"
    end
  end

  defp resolve_price_summary_label(%Event{minimum_ticket_price: min, maximum_ticket_price: max}) do
    if min == max do
      "#{resolve_min_price_label(min)}"
    else
      "#{resolve_min_price_label(min)}+"
    end
  end

  defp resolve_price_range_label(%Event{minimum_ticket_price: min, maximum_ticket_price: max}) do
    if min == max do
      "#{resolve_min_price_label(min)}"
    else
      "#{resolve_min_price_label(min)} - R#{max |> Gits.Currency.format()}"
    end
  end

  embed_templates "page_html/*"
end
