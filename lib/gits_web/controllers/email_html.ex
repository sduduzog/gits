defmodule GitsWeb.EmailHTML do
  use GitsWeb, :html
  use GitsWeb, :verified_routes

  embed_templates "email_html/*"

  def layout(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>MyApp Email</title>
      </head>

      <body><%= @inner_content %></body>
    </html>
    """
  end
end
