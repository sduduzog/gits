defmodule GitsWeb.Router do
  use GitsWeb, :router

  use AshAuthentication.Phoenix.Router

  import Phoenix.LiveDashboard.Router
  import Oban.Web.Router

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
    get "/organizers", PageController, :organizers
    get "/host-with-us", PageController, :host
    get "/faqs", PageController, :faqs
    get "/healthz", PageController, :healthz
    get "/storyblok", StoryblokController, :admin
    get "/orders/paystack/callback", OrderController, :paystack_callback

    resources "/accounts", AccountController, only: [:index]

    get "/sign-in", AuthController, :sign_in
    get "/sign-out", AuthController, :sign_out

    get "/bucket/*keys", PageController, :bucket

    live_session :user_optional, on_mount: {GitsWeb.LiveUserAuthOld, :live_user_optional} do
      live "/search", SearchLive, :index
      live "/tickets/:public_id", TicketLive, :show
      live "/t/:public_id", TicketLive, :show
      live "/t/:public_id/rsvp", TicketLive, :rsvp
      live "/refund", RefundLive, :index
      live "/pricing", PricingLive, :index
    end

    live_session :user_required, on_mount: {GitsWeb.LiveUserAuthOld, :live_user_required} do
      live "/settings/profile", SettingsLive.Profile, :index
      live "/hosts/get-started", HostLive.Onboarding, :get_started
      live "/hosts/:handle/dashboard", HostLive.Dashboard, :home
      live "/hosts/:handle/events", HostLive.Events, :index

      live "/hosts/:handle/events/create", HostLive.Events, :details
      live "/hosts/:handle/events/:public_id", HostLive.Events, :dashboard
      live "/hosts/:handle/events/:public_id/details", HostLive.Events, :details
      live "/hosts/:handle/events/:public_id/tickets", HostLive.Events, :tickets
      live "/hosts/:handle/events/:public_id/admissions", HostLive.Events, :admissions
      live "/hosts/:handle/events/:public_id/settings", HostLive.Events, :settings

      live "/hosts/:handle/events/:public_id/scanner", HostLive.Scanner, :index
      live "/hosts/:handle/events/:public_id/scanner/:camera", HostLive.Scanner, :scan

      live "/hosts/:handle/orders", HostLive.Orders, :index

      live "/hosts/:handle/support", HostLive.SupportBoard, :index

      live "/hosts/:handle/settings", HostLive.Settings, :index
      live "/hosts/:handle/settings/general", HostLive.Settings, :general
      live "/hosts/:handle/settings/billing", HostLive.Settings, :billing
      live "/hosts/:handle/settings/api", HostLive.Settings, :api
    end

    ash_authentication_live_session :authenticated_routes do
      live "/settings", SettingsLive.Index
      live "/hosts/:handle/team/members", HostLive.Team, :members
    end
  end

  scope "/events/:public_id", GitsWeb do
    pipe_through :browser

    live_session :events_authentication_optional,
      on_mount: {GitsWeb.LiveUserAuthOld, :live_user_optional} do
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
      on_mount: {GitsWeb.LiveUserAuthOld, :my_live} do
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

    live_session :admin_required, on_mount: {GitsWeb.LiveUserAuthOld, :live_user_required} do
      live "/", AdminLive.Index, :dashboard
      live "/jobs", AdminLive.Index, :jobs
      live "/hosts", AdminLive.Index, :hosts
      live "/users", AdminLive.Index, :users
      live "/events", AdminLive.Index, :events
      live "/support", AdminLive.Index, :support
      # remove when done with onboarding on all environments
      live "/start", AdminLive, :start
    end

    oban_dashboard("/oban")

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

  scope "/*path", GitsWeb do
    pipe_through [:browser]
    get "/", StoryblokController, :show
  end
end
