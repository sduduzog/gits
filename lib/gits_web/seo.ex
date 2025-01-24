defmodule GitsWeb.SEO do
  use GitsWeb, :verified_routes

  use SEO,
    site: &__MODULE__.site_config/1,
    open_graph: &__MODULE__.og_config/1,
    twitter: &__MODULE__.twitter_build/1

  def site_config(conn) do
    SEO.Site.build(
      default_title: "GiTS - Ticketing & events",
      title_suffix: " - GiTS",
      description: "Unlock Unforgettable Experiences",
      manifest_url: url(conn, ~p"/site.webmanifest")
    )
  end

  def twitter_build(conn) do
    SEO.Twitter.build(
      site: "@gits_za",
      creator: "@sduduzo_g",
      card: :summary_large_image,
      image: static_url(conn, "/images/gits_site_cover.png")
    )
  end

  def og_config(conn) do
    SEO.OpenGraph.build(
      description: "Unlock Unforgettable Experiences",
      site_name: "GiTS",
      image: static_url(conn, "/images/gits_site_cover.png")
    )
  end
end

defimpl SEO.OpenGraph.Build, for: Gits.Storefront.Event do
  use GitsWeb, :verified_routes

  def build(event, conn) do
    SEO.OpenGraph.build(
      detail:
        SEO.OpenGraph.Article.build(
          published_time: event.published_at || event.updated_at,
          author: "GiTS"
        ),
      image: image(event, conn),
      title: event.name,
      description: event.summary
    )
  end

  defp image(event, _) do
    SEO.OpenGraph.Image.build(
      url: event.poster.url,
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
    SEO.Twitter.build(description: event.summary, title: event.name, image: event.poster.url)
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
