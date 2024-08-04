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
    pipe_through :browser

    sign_out_route AuthController
    auth_routes_for Gits.Auth.User, to: AuthController

    get "/", PageController, :home
    get "/events", PageController, :events
    get "/organizers", PageController, :organizers
    get "/healthz", PageController, :healthz

    resources "/accounts", AccountController, only: [:index, :new, :create]

    get "/sign-in", AuthController, :sign_in
    get "/register", AuthController, :register
    get "/forgot-password", AuthController, :forgot_password
    get "/resend-verification", AuthController, :resend_verification_email
    sign_out_route AuthController
    auth_routes_for Gits.Auth.User, to: AuthController

    get "/bucket/*keys", PageController, :bucket

    ash_authentication_live_session :authentication_optional,
      on_mount: {GitsWeb.LiveUserAuth, :live_user_optional} do
      live "/events/:id", EventLive.Feature
    end

    ash_authentication_live_session :authentication_required,
      on_mount: {GitsWeb.LiveUserAuth, :live_user_required} do
      live "/events/:id/tickets/:basket_id", EventLive.Tickets
      live "/events/:id/tickets/:basket_id/summary", EventLive.TicketsSummary
      live "/events/:id/tickets/:basket_id/checkout", EventLive.Checkout

      live "/accounts/:account_id/events/:event_id/address", EventAddressLive
      live "/attendees/scanner/:account_id/:event_id", ScanAttendeeLive
      live "/accounts/:slug", DashboardLive.Home
      live "/accounts/:slug/events", DashboardLive.Events
      live "/accounts/:slug/events/new", DashboardLive.ManageEvent
      live "/accounts/:slug/events/:event_id", DashboardLive.Event
      live "/accounts/:slug/events/:event_id/edit", DashboardLive.ManageEvent
      live "/accounts/:slug/events/:event_id/scan", DashboardLive.ScanTickets

      live "/accounts/:slug/events/:event_id/upload-graphics", DashboardLive.UploadGraphic
      live "/accounts/:slug/team", DashboardLive.Team
      live "/accounts/:slug/team/invites/new", DashboardLive.TeamInviteNewMember
      live "/accounts/:slug/team/invites/:invite_id", DashboardLive.TeamInvite
      live "/accounts/:slug/settings", DashboardLive.Settings
      live "/accounts/:slug/settings/paystack", DashboardLive.SetupPaystack
    end

    ash_authentication_live_session :authentication_forbidden,
      on_mount: {GitsWeb.LiveUserAuth, :live_no_user} do
      live "/password-reset/:token", AuthLive.PasswordReset
    end
  end

  scope "/my", GitsWeb do
    pipe_through :browser
    get "/profile", UserController, :settings
    get "/profile/settings", UserController, :settings
    get "/tickets", UserController, :tickets
    get "/tickets/past", UserController, :past_tickets
    get "/tickets/:token", UserController, :ticket
  end

  scope "/admin" do
    pipe_through [:browser, :office]

    live_dashboard "/dashboard",
      metrics: GitsWeb.Telemetry,
      additional_pages: [oban: Oban.LiveDashboard]
  end

  scope "/admin/flags" do
    pipe_through [:browser, :office]
    forward "/", FunWithFlags.UI.Router, namespace: "admin/flags"
  end

  if Application.compile_env(:gits, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview

      get "/email", GitsWeb.EmailController, :test
    end
  end
end
