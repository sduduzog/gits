defmodule GitsWeb.StoryblokController do
  use GitsWeb, :controller

  def admin(conn, _) do
    conn |> put_layout(false) |> render(:admin)
  end

  def show(conn, params) do
    path =
      case params do
        %{"path" => path_list} -> Enum.join(path_list, "/")
        _ -> ""
      end

    {token, version, cv} =
      case params do
        %{"_storyblok_tk" => %{"timestamp" => cv}} ->
          token =
            Application.get_env(:gits, :storyblok)
            |> Keyword.get(:preview_token)

          {token, "draft", cv}

        _ ->
          token =
            Application.get_env(:gits, :storyblok)
            |> Keyword.get(:public_token)

          ts =
            DateTime.to_unix(DateTime.utc_now(), :millisecond)
            |> to_string()

          {token, "published", ts}
      end

    Req.get(
      "https://api.storyblok.com/v2/cdn/stories/#{path}?token=#{token}&version=#{version}&cv=#{cv}"
    )
    |> case do
      {:ok, %{body: %{"story" => story}}} ->
        conn
        |> assign(:page_title, story["name"])
        |> assign(:story, story)
        |> render(:story)

      _ ->
        conn
        |> put_layout(html: :not_found)
        |> render(:story)
    end
  end
end
