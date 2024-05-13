defmodule GitsWeb.Router do
  use GitsWeb, :router
  use AshAuthentication.Phoenix.Router

  import Phoenix.LiveDashboard.Router
  import Plug.BasicAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GitsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :office do
    plug :basic_auth, username: "sdu", password: "cheese and onions"
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GitsWeb do
    pipe_through [:browser]

    resources "/accounts", AccountController do
      resources "/events", EventController do
        resources "/attendees", AttendeeController
        resources "/tickets", TicketController
        get "/settings", EventController, :settings
        get "/upload/listing", EventController, :upload_listing_image
        get "/upload/feature", EventController, :upload_feature_image
      end

      resources "/team", TeamMemberController, only: [:index]

      resources "/invites", TeamInviteController
    end
  end

  scope "/", GitsWeb do
    pipe_through :browser

    sign_out_route AuthController
    auth_routes_for Gits.Auth.User, to: AuthController

    get "/", PageController, :home
    get "/tickets", PageController, :tickets
    get "/organizers", PageController, :organizers
    get "/search", PageController, :search
    get "/join-waitlist", PageController, :join_wailtist
    get "/faq", PageController, :faq

    ash_authentication_live_session :authentication_optional,
      on_mount: {GitsWeb.LiveUserAuth, :live_user_optional} do
      live "/events/:id", EventLive
      live "/events/:id/payment", EventLive.Payment
    end

    ash_authentication_live_session :authentication_required,
      on_mount: {GitsWeb.LiveUserAuth, :live_user_required} do
      live "/accounts/:account_id/events/:event_id/address", EventAddressLive
      live "/attendees/scanner/:account_id/:event_id", ScanAttendeeLive
    end

    ash_authentication_live_session :authentication_forbidden,
      on_mount: {GitsWeb.LiveUserAuth, :live_no_user} do
      live "/password-reset/:token", AuthLive.PasswordReset
    end

    get "/sign-in", AuthController, :sign_in
    get "/register", AuthController, :register
    get "/forgot-password", AuthController, :forgot_password
    get "/resend-verification", AuthController, :resend_verification_email
    sign_out_route AuthController
    auth_routes_for Gits.Auth.User, to: AuthController

    get "/bucket/*keys", PageController, :bucket
  end

  # Other scopes may use custom stacks.
  # scope "/api", GitsWeb do
  #   pipe_through :api
  # end

  scope "/office" do
    pipe_through [:browser, :office]

    live_dashboard "/dashboard",
      metrics: GitsWeb.Telemetry,
      additional_pages: [oban: Oban.LiveDashboard]
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:gits, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).

    scope "/dev" do
      pipe_through :browser

      # live_dashboard "/dashboard",
      #   metrics: GitsWeb.Telemetry,
      #   additional_pages: [oban: Oban.LiveDashboard]

      forward "/mailbox", Plug.Swoosh.MailboxPreview

      get "/email", GitsWeb.EmailController, :test
    end
  end
end
