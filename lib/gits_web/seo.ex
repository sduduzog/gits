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
      description: event.summary
    )
  end

  defp image(event, _) do
    file = Gits.Bucket.get_image_url(event.poster)

    SEO.OpenGraph.Image.build(
      url: file,
      alt: event.name
    )
  end
end

defimpl SEO.Site.Build, for: Gits.Storefront.Event do
  use GitsWeb, :verified_routes

  def build(event, conn) do
    SEO.Site.build(
      url: url(conn, ~p"/events/#{event.public_id}"),
      title: event.name,
      description: event.summary
    )
  end
end

defimpl SEO.Twitter.Build, for: Gits.Storefront.Event do
  def build(event, _conn) do
    SEO.Twitter.build(description: event.summary, title: event.name)
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
      %{name: event.name, item: url(conn, ~p"/events/#{event.public_id}")}
    ])
  end
end
