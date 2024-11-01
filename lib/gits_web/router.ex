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

    resources "/accounts", AccountController, only: [:index]

    get "/sign-in", AuthController, :sign_in
    get "/sign-out", AuthController, :sign_out

    get "/bucket/*keys", PageController, :bucket

    live "/search", SearchLive, :index
  end

  scope "/hosts", GitsWeb do
    pipe_through :browser

    live_session :hosts_authentication,
      on_mount: {GitsWeb.LiveUserAuth, :host} do
      live "/get-started", HostLive.Onboarding, :get_started

      live "/:handle/dashboard", HostLive.Dashboard, :overview

      live "/:handle/events", HostLive.ListEvents, :published
      live "/:handle/events/drafts", HostLive.ListEvents, :drafts
      live "/:handle/events/all", HostLive.ListEvents, :all

      live "/:handle/events/create-new", HostLive.EditEvent, :details

      live "/:handle/events/:public_id", HostLive.ViewEvent, :tickets

      live "/:handle/events/:public_id/edit/details", HostLive.EditEvent, :details

      live "/:handle/events/:public_id/edit/time-and-place",
           HostLive.EditEvent,
           :time_and_place

      live "/:handle/events/:public_id/edit/tickets",
           HostLive.EditEvent,
           :tickets

      live "/hosts/:handle/events/:event_id/settings/payout-preferences",
           HostLive.EventView,
           :settings_payout_preferences

      live "/hosts/:handle/events/:event_id/manage",
           HostLive.EditEvent,
           :summary

      live "/hosts/:handle/events/:event_id/attendees", HostLive.EventView, :attendees

      live "/hosts/:handle/events/:event_id/attendees/scanner",
           HostLive.Scanner,
           :choose_camera

      live "/hosts/:handle/events/:event_id/attendees/scanner/:camera",
           HostLive.Scanner,
           :scan

      live "/hosts/:handle/events/:event_id/guests", HostLive.Event, :guests

      live "/hosts/:handle/settings/payouts", HostLive.Settings, :payouts
      live "/hosts/:handle/settings", HostLive.Settings, :general
    end
  end

  scope "/events/:public_id", GitsWeb do
    pipe_through :browser

    live_session :events_authentication_optional,
      on_mount: {GitsWeb.LiveUserAuth, :live_user_optional} do
      live "/", StorefrontLive.EventListing, :index
      live "/order", StorefrontLive.EventListing, :order
    end
  end

  scope "/auth" do
    pipe_through :browser
    forward "/", GitsWeb.AuthPlug
  end

  scope "/my", GitsWeb do
    pipe_through :browser

    live_session :my_authentication_required,
      on_mount: {GitsWeb.LiveUserAuth, :my_live} do
      live "/tickets", MyLive, :tickets
      live "/orders", MyLive, :orders
      live "/profile", MyLive, :profile
    end
  end

  scope "/admin" do
    pipe_through [:browser, :office]

    live_dashboard "/dashboard",
      ecto_repos: [Gits.Repo],
      ecto_psql_extras_options: [long_running_queries: [threshold: "20 milliseconds"]],
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
