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

      resources "/invites", TeamInviteController do
        post "/resend", TeamInviteController, :resend_invite
      end
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
    get "/healthz", PageController, :healthz

    ash_authentication_live_session :authentication_optional,
      on_mount: {GitsWeb.LiveUserAuth, :live_user_optional} do
      live "/events/:id", EventLive
      live "/events/:id/payment", EventLive.Payment
    end

    ash_authentication_live_session :authentication_required,
      on_mount: {GitsWeb.LiveUserAuth, :live_user_required} do
      live "/accounts/:account_id/events/:event_id/address", EventAddressLive
      live "/attendees/scanner/:account_id/:event_id", ScanAttendeeLive
      live "/accounts/:slug/next", DashboardLive.Overview
      live "/accounts/:slug/next/events", DashboardLive.Events
      live "/accounts/:slug/next/events/:event_id", DashboardLive.EventDetails
      live "/accounts/:slug/next/team", DashboardLive.Team
      live "/accounts/:slug/next/settings", DashboardLive.Settings
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

  scope "/office" do
    pipe_through [:browser, :office]

    live_dashboard "/dashboard",
      metrics: GitsWeb.Telemetry,
      additional_pages: [oban: Oban.LiveDashboard]
  end

  if Application.compile_env(:gits, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview

      get "/email", GitsWeb.EmailController, :test
    end
  end
end
