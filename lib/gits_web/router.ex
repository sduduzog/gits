defmodule GitsWeb.Router do
  use GitsWeb, :router

  import Phoenix.LiveDashboard.Router
  import Plug.BasicAuth
  import GitsWeb.AuthPlug

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

    live_session :authentication_required,
      on_mount: {GitsWeb.LiveUserAuth, :live_user_required} do
      live "/hosts/sign-up", HostLive.Onboarding, :sign_up
      live "/hosts/:handle/onboarding/create-event", HostLive.Onboarding, :create_event

      live "/hosts/:handle/onboarding/:event_id/time-and-place",
           HostLive.Onboarding,
           :time_and_place

      live "/hosts/:handle/onboarding/:event_id/add-tickets",
           HostLive.Onboarding,
           :add_tickets

      live "/hosts/:handle/onboarding/:event_id/payout-information",
           HostLive.Onboarding,
           :payout_information

      live "/hosts/:handle/onboarding/:event_id/summary",
           HostLive.Onboarding,
           :summary

      live "/hosts/:handle/onboarding", HostLive.Onboarding, :payouts
      live "/hosts/:handle/onboarding/invite-team", HostLive.Onboarding, :invite_team
      live "/hosts/:handle/onboarding/", HostLive.Onboarding, :payouts
      live "/hosts/:handle/dashboard", HostLive.Dashboard
      live "/hosts/:handle/events", HostLive.EventList
      live "/hosts/:handle/create-event", HostLive.ManageEvent, :create
      live "/hosts/:handle/events/:event_id/manage", HostLive.ManageEvent, :edit
      live "/hosts/:handle/events/:event_id", HostLive.EventOverview
      live "/hosts/:handle/settings/payouts", HostLive.Settings, :payouts
      live "/hosts/:handle/settings", HostLive.Settings, :general

      live "/events/:id/tickets/:basket_id", EventLive.Tickets
      live "/events/:id/tickets/:basket_id/summary", EventLive.TicketsSummary
      live "/events/:id/tickets/:basket_id/checkout", EventLive.Checkout

      live "/attendees/scanner/:account_id/:event_id", ScanAttendeeLive

      live "/portal/support", SupportLive
      live "/portal/support/users", SupportLive, :users
      live "/portal/support/jobs", SupportLive, :jobs
      live "/portal/support/accounts", SupportLive, :accounts
      live "/portal/support/events", SupportLive, :events
    end

    get "/", PageController, :home
    get "/events", PageController, :events
    get "/settings", PageController, :settings
    get "/organizers", PageController, :organizers
    get "/host-with-us", PageController, :host
    get "/privacy", PageController, :privacy
    get "/terms", PageController, :terms
    get "/help", PageController, :help
    get "/faq", PageController, :faq
    get "/assets/:filename", PageController, :assets
    get "/healthz", PageController, :healthz
    get "/beta", PageController, :beta

    resources "/search", SearchController, only: [:index]
    resources "/accounts", AccountController, only: [:index]

    get "/sign-in", AuthController, :sign_in
    get "/register", AuthController, :register
    get "/forgot-password", AuthController, :forgot_password
    post "/request-magic-link", AuthController, :request_magic_link
    get "/magic-link-sent", AuthController, :magic_link_sent
    post "/resend-verification", AuthController, :resend_verification_email
    get "/email-not-verified", AuthController, :email_not_verified
    get "/sign-out", AuthController, :sign_out

    get "/bucket/*keys", PageController, :bucket

    live_session :authentication_optional,
      on_mount: {GitsWeb.LiveUserAuth, :live_user_optional} do
      live "/events/:id", EventLive.Feature
      live "/ticket-invite/:invite_id", EventLive.Invite
    end

    live_session :authentication_forbidden,
      on_mount: {GitsWeb.LiveUserAuth, :live_no_user} do
      live "/password-reset/:token", AuthLive.PasswordReset
    end
  end

  scope "/auth" do
    pipe_through :browser
    forward "/", GitsWeb.AuthPlug
  end

  scope "/my", GitsWeb do
    pipe_through :browser
    get "/profile", UserController, :profile
    get "/profile/edit", UserController, :edit_profile
    get "/profile/login-and-security", UserController, :login_and_security
    get "/tickets", UserController, :tickets
    get "/tickets/past", UserController, :past_tickets
    get "/tickets/:token", UserController, :ticket
  end

  scope "/admin" do
    pipe_through [:browser, :office]

    live_dashboard "/dashboard",
      ecto_repos: [Gits.Repo],
      ecto_psql_extras_options: [long_running_queries: [threshold: "20 milliseconds"]],
      metrics: GitsWeb.Telemetry,
      additional_pages: [oban: Oban.LiveDashboard]

    forward "/flags", FunWithFlags.UI.Router, namespace: "admin/flags"
  end

  if Application.compile_env(:gits, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview

      get "/email", GitsWeb.EmailController, :test
    end
  end
end
