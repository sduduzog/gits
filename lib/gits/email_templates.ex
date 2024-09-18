defmodule Gits.EmailTemplates do
  use Phoenix.Component
  use GitsWeb, :verified_routes

  def render_magic_link(token) do
    %{token: token}
    |> magic_link()
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
  end

  def render_email_confirmation_link(token) do
    %{token: token}
    |> email_confirmation_link()
    |> Phoenix.HTML.Safe.to_iodata()
    |> IO.iodata_to_binary()
  end

  def magic_link(assigns) do
    ~H"""
    <.layout preheader="Hey! Welcome back!">
      <p style="margin: 10px 0; line-height: 20px">
        If you didn't request this e-mail, there's nothing to worry about — you can safely ignore it.
      </p>
      <br />
      <a
        style="text-decoration: none; font-weight: 600; color: #fafafa; background-color: #18181b; padding: 10px 15px; border-radius: 10px;"
        href={unverified_url(GitsWeb.Endpoint, ~p"/auth/user/magic_link?token=#{@token}")}
        target="_blank"
      >
        Sign in now
      </a>
    </.layout>
    """
  end

  def email_confirmation_link(assigns) do
    ~H"""
    <.layout preheader="Hey! Welcome!">
      <p style="margin: 10px 0; line-height: 20px">
        If you didn't request this e-mail, there's nothing to worry about — you can safely ignore it.
      </p>
      <br />
      <a
        style="text-decoration: none; font-weight: 600; color: #fafafa; background-color: #18181b; padding: 10px 15px; border-radius: 10px;"
        href={unverified_url(GitsWeb.Endpoint, ~p"/auth/user/confirm/?confirm=#{@token}")}
        target="_blank"
      >
        Sign in now
      </a>
    </.layout>
    """
  end

  def layout(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta name="x-apple-disable-message-reformatting" />
        <meta name="format-detection" content="telephone=no, date=no, address=no, email=no, url=no" />
        <meta name="color-scheme" content="light dark" />
        <meta name="supported-color-schemes" content="light dark" />
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
        <link
          href="https://fonts.googleapis.com/css2?family=Poppins:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap"
          rel="stylesheet"
        />
      </head>
      <body style="margin: 0; width: 100%; padding: 0; background-color: #ffffff; -webkit-font-smoothing: antialiased; word-break: break-word;">
        <div style="display: none;"><%= @preheader %></div>
        <div
          style="font-family: Poppins, Arial, ui-sans-serif, system-ui, -apple-system, 'Segoe UI', sans-serif"
          role="article"
          aria-roledescription="email"
          aria-label="Confirm your email address"
          lang="en"
        >
          <div style="padding: 16px;">
            <table align="center" cellpadding="0" cellspacing="0" role="none">
              <tr>
                <td style="width: 552px; max-width: 100%;">
                  <table style="width: 100%;" cellpadding="0" cellspacing="0" role="none">
                    <tr>
                      <td style="font-size: 14px; padding: 24px;">
                        <p style="width: 50px">
                          <a
                            style="text-decoration: none; color: #09090b;"
                            href={url(GitsWeb.Endpoint, ~p"/")}
                            target="_blank"
                          >
                            <img
                              src={static_url(GitsWeb.Endpoint, ~p"/images/gits_logo.png")}
                              style="height: auto; width: 100%;"
                              alt="GiTS"
                            />
                          </a>
                        </p>

                        <h1 style="font-size: 24px; font-weight: 600; margin: 0 0 24px;">
                          <%= @preheader %>
                        </h1>
                        <%= render_slot(@inner_block) %>
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>
              <tr>
                <td style="padding: 24px;"></td>
              </tr>
            </table>
          </div>
        </div>
      </body>
    </html>
    """
  end
end
