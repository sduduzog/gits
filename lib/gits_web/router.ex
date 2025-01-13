defmodule GitsWeb.Router do
  use GitsWeb, :router

  import Phoenix.LiveDashboard.Router
  import GitsWeb.AuthPlug

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GitsWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
    plug :ensure_viewer_id
  end

  defp ensure_viewer_id(conn, _opts) do
    if get_session(conn, :viewer_id) do
      conn
    else
      viewer_id = :crypto.strong_rand_bytes(20) |> Base.encode64()
      put_session(conn, :viewer_id, viewer_id)
    end
  end

  defp basic_auth(conn, _opts) do
    Plug.BasicAuth.basic_auth(conn, Application.get_env(:gits, :basic_auth))
  end

  pipeline :admin do
    plug :basic_auth
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
    get "/support/faq", PageController, :faq
    get "/contact-us", PageController, :contact_us
    get "/assets/:filename", PageController, :assets
    get "/healthz", PageController, :healthz
    get "/beta", PageController, :beta
    get "/orders/paystack/callback", OrderController, :paystack_callback

    resources "/accounts", AccountController, only: [:index]

    get "/sign-in", AuthController, :sign_in
    get "/sign-out", AuthController, :sign_out

    get "/bucket/*keys", PageController, :bucket

    live_session :user_optional, on_mount: {GitsWeb.LiveUserAuth, :live_user_optional} do
      live "/search", SearchLive, :index
      live "/tickets/:public_id", TicketLive, :show
      live "/t/:public_id", TicketLive, :show
      live "/t/:public_id/rsvp", TicketLive, :rsvp
      live "/refund", RefundLive, :index
    end

    live_session :user_required, on_mount: {GitsWeb.LiveUserAuth, :live_user_required} do
      live "/settings/profile", SettingsLive.Profile, :index
      live "/hosts/get-started", HostLive.Onboarding, :get_started
      live "/hosts/:handle/dashboard", HostLive.Dashboard, :overview
      live "/hosts/:handle/events/published", HostLive.ListEvents, :published
      live "/hosts/:handle/events/drafts", HostLive.ListEvents, :drafts
      live "/hosts/:handle/events/archived", HostLive.ListEvents, :archived
      live "/hosts/:handle/events", HostLive.ListEvents, :all
      live "/hosts/:handle/events/create-new", HostLive.EditEvent, :details
      live "/hosts/:handle/events/:public_id", HostLive.ViewEvent, :overview
      live "/hosts/:handle/events/:public_id/attendees", HostLive.ViewEvent, :attendees
      live "/hosts/:handle/events/:public_id/edit/details", HostLive.EditEvent, :details
      live "/hosts/:handle/events/:public_id/edit/location", HostLive.EditEvent, :location
      live "/hosts/:handle/events/:public_id/edit/live-stream", HostLive.EditEvent, :live_stream
      live "/hosts/:handle/events/:public_id/edit/description", HostLive.EditEvent, :description
      live "/hosts/:handle/events/:public_id/edit/media", HostLive.EditEvent, :media
      live "/hosts/:handle/events/:public_id/edit/tickets", HostLive.EditEvent, :tickets
      live "/hosts/:handle/events/:public_id/edit/tickets/add", HostLive.EditTicket, :add_ticket

      live "/hosts/:handle/events/:public_id/edit/tickets/:ticket_id",
           HostLive.EditTicket,
           :edit_ticket

      live "/hosts/:handle/events/:public_id/scanner", HostLive.Scanner, :index
      live "/hosts/:handle/events/:public_id/scanner/:camera", HostLive.Scanner, :scan

      live "/hosts/:handle/orders", HostLive.Orders, :index

      live "/hosts/:handle/venues/create-new", HostLive.EditVenue, :create
      live "/hosts/:handle/support", HostLive.SupportBoard, :index

      live "/hosts/:handle/settings", HostLive.Settings, :index
      live "/hosts/:handle/settings/general", HostLive.Settings, :general
      live "/hosts/:handle/settings/billing", HostLive.Settings, :billing
    end
  end

  scope "/events/:public_id", GitsWeb do
    pipe_through :browser

    live_session :events_authentication_optional,
      on_mount: {GitsWeb.LiveUserAuth, :live_user_optional} do
      live "/", StorefrontLive.EventListing, :index
      live "/order/:order_id", StorefrontLive.EventOrder, :index
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
      live "/tickets", MyLive.Tickets, :index
      live "/tickets/:public_id", MyLive.Tickets, :show
      live "/orders", MyLive.Orders, :index
      live "/orders/:order_id", MyLive.Orders, :show
      live "/settings", MyLive.Settings, :profile
      live "/settings/partner", MyLive.Settings, :partner
    end
  end

  scope "/admin", GitsWeb do
    pipe_through [:browser, :admin]

    live_session :admin_required, on_mount: {GitsWeb.LiveUserAuth, :live_user_required} do
      live "/", AdminLive.Index, :dashboard
      live "/jobs", AdminLive.Index, :jobs
      live "/hosts", AdminLive.Index, :hosts
      live "/users", AdminLive.Index, :users
      live "/events", AdminLive.Index, :events
      live "/support", AdminLive.Index, :support
      # remove when done with onboarding on all environments
      live "/start", AdminLive, :start
    end

    live_dashboard "/dashboard",
      ecto_repos: [Gits.Repo],
      ecto_psql_extras_options: [long_running_queries: [threshold: "5 milliseconds"]],
      metrics: GitsWeb.Telemetry
  end

  scope "/webhooks", GitsWeb do
    pipe_through :api
    post "/paystack", WebhookController, :paystack
  end

  if Application.compile_env(:gits, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview

      get "/email", GitsWeb.EmailController, :test
    end
  end
end
