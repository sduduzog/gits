defmodule GitsWeb.StoryblokHTML do
  use GitsWeb, :html

  embed_templates "storyblok_html/*"

  def blok(%{story: %{"component" => "page"}} = assigns) do
    ~H"""
    <.blok :for={blok <- @story["body"]} story={blok} />
    """
  end

  def blok(%{story: %{"component" => "article"}} = assigns) do
    ~H"""
    <div>
      <.blok :for={blok <- @story["body"]["content"]} story={blok} />
    </div>
    """
  end

  def blok(%{story: %{"type" => "text"}} = assigns) do
    if assigns.story["marks"] == nil or assigns.story["marks"] == [] do
      ~H"""
      {@story["text"]}
      """
    else
      assigns.story["marks"]
      |> hd()
      |> case do
        %{"type" => "bold"} ->
          ~H"""
          <strong>
            <.blok story={%{"type" => "text", "text" => @story["text"], "marks" => tl(@story["marks"])}} />
          </strong>
          """

        %{"type" => "italic"} ->
          ~H"""
          <span class="italic">
            <.blok story={%{"type" => "text", "text" => @story["text"], "marks" => tl(@story["marks"])}} />
          </span>
          """

        %{"type" => "link", "attrs" => attrs} ->
          assigns = assign(assigns, :attrs, attrs)

          ~H"""
          <a href={@attrs["href"]} class="text-brand-base hover:underline font-medium">
            <.blok story={%{"type" => "text", "text" => @story["text"], "marks" => tl(@story["marks"])}} />
          </a>
          """
      end
    end
  end

  def blok(%{story: %{"type" => "text"}} = assigns) do
    ~H"""
    {@story["text"]}
    """
  end

  def blok(%{story: %{"type" => "heading"}} = assigns) do
    ~H"""
    <.heading attrs={@story["attrs"]}>
      <.blok :for={blok <- @story["content"]} story={blok} />
    </.heading>
    """
  end

  def blok(%{story: %{"type" => "paragraph"}} = assigns) do
    ~H"""
    <p class="leading-6">
      <.blok :for={blok <- @story["content"]} story={blok} />
    </p>
    """
  end

  def blok(%{story: %{"type" => "bullet_list"}} = assigns) do
    ~H"""
    <ul class="list-disc pl-5">
      <.blok :for={blok <- @story["content"]} story={blok} />
    </ul>
    """
  end

  def blok(%{story: %{"type" => "list_item"}} = assigns) do
    ~H"""
    <li>
      <.blok :for={blok <- @story["content"]} story={blok} />
    </li>
    """
  end

  def blok(%{story: %{"type" => _}} = assigns) do
    ~H"""
    <div>list</div>
    """
  end

  def blok(assigns) do
    ~H"""
    <div>blok</div>
    """
  end

  defp heading(%{attrs: %{"level" => 4}} = assigns) do
    ~H"""
    <h4 class="text-lg/8 font-semibold">{render_slot(@inner_block)}</h4>
    """
  end

  defp heading(%{attrs: %{"level" => 3}} = assigns) do
    ~H"""
    <h3 class="text-xl/8 my-1 font-semibold text-brand-950">{render_slot(@inner_block)}</h3>
    """
  end

  defp heading(%{attrs: %{"level" => 2}} = assigns) do
    ~H"""
    <h2 class="text-2xl/8 my-2 text-brand-900 font-medium">{render_slot(@inner_block)}</h2>
    """
  end

  defp heading(%{attrs: %{"level" => _}} = assigns) do
    ~H"""
    <h1 class="text-4xl/8 text-brand-800 my-4 font-semibold">{render_slot(@inner_block)}</h1>
    """
  end
end
