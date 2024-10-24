defmodule GitsWeb.SEO do
  use GitsWeb, :verified_routes

  use SEO,
    site: &__MODULE__.site_config/1,
    open_graph:
      SEO.OpenGraph.build(description: "Easy events, affordable tickets", site_name: "GiTS"),
    twitter:
      SEO.Twitter.build(
        site: "@gits_za",
        creator: "@sduduzo_g",
        card: :summary_large_image
      )

  def site_config(_conn) do
    SEO.Site.build(
      default_title: "GiTS - Ticketing & events",
      title_suffix: " - GiTS",
      description: "Easy events, affortable tickets",
      manifest_url: "/site.webmanifest"
    )
  end
end

defimpl SEO.OpenGraph.Build, for: Gits.Storefront.Event do
  use GitsWeb, :verified_routes

  def build(event, conn) do
    SEO.OpenGraph.build(
      detail:
        SEO.OpenGraph.Article.build(
          published_time: event.updated_at,
          author: "GiTS"
        ),
      image: image(event, conn),
      title: event.name,
      description: event.description
    )
  end

  defp image(event, conn) do
    file = Gits.Bucket.get_feature_image_path(event.account_id, event.id)

    if Gits.Bucket.feature_image_exists?(event.account_id, event.id) do
      SEO.OpenGraph.Image.build(
        url: static_url(conn, file),
        alt: event.name
      )
    end
  end
end

defimpl SEO.Site.Build, for: Gits.Storefront.Event do
  use GitsWeb, :verified_routes

  def build(event, conn) do
    SEO.Site.build(
      url: url(conn, ~p"/events/#{event.masked_id}"),
      title: event.name,
      description: event.description
    )
  end
end

defimpl SEO.Twitter.Build, for: Gits.Storefront.Event do
  def build(event, _conn) do
    SEO.Twitter.build(description: event.description, title: event.name)
  end
end

defimpl SEO.Unfurl.Build, for: Gits.Storefront.Event do
  def build(event, _conn) do
    SEO.Unfurl.build(
      label1: "Updated",
      data1: DateTime.to_iso8601(event.updated_at)
    )
  end
end

defimpl SEO.Breadcrumb.Build, for: Gits.Storefront.Event do
  use GitsWeb, :verified_routes

  def build(event, conn) do
    SEO.Breadcrumb.List.build([
      %{name: "Events", item: url(conn, ~p"/events")},
      %{name: event.name, item: url(conn, ~p"/events/#{event.masked_id}")}
    ])
  end
end
