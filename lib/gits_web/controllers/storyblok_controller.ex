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
          {token, cv} = get_token_and_version()

          {token, "published", cv}
      end

    fetch_stories(path, token, version, cv)
    |> case do
      %{} = story ->
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

  defp get_token_and_version() do
    token =
      Application.get_env(:gits, :storyblok)
      |> Keyword.get(:public_token)

    url = "https://api.storyblok.com/v2/cdn/spaces/me?token=#{token}"

    Cachex.fetch(:cache, url, fn key ->
      Req.get(key)
      |> case do
        {:ok, %{body: body}} ->
          {:commit, body["space"]["version"], expire: :timer.seconds(3600)}

        _ ->
          {:ignore, nil}
      end
    end)
    |> case do
      {_, response, _} -> {token, response}
      {_, response} -> {token, response}
    end
  end

  defp fetch_stories(path, token, version, cv) do
    url =
      "https://api.storyblok.com/v2/cdn/stories/#{path}?token=#{token}&version=#{version}&cv=#{cv}"

    Cachex.fetch(:cache, url, fn key ->
      Req.get(key)
      |> case do
        {:ok, %{body: %{"story" => story}}} ->
          {:commit, story, expire: :timer.seconds(3600)}

        _ ->
          {:ignore, nil}
      end
    end)
    |> case do
      {_, response, _} -> response
      {_, response} -> response
    end
  end
end
