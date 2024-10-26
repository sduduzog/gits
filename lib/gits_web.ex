defmodule GitsWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use GitsWeb, :controller
      use GitsWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths,
    do:
      ~w(assets fonts images .well-known favicon.ico robots.txt android-chrome-192x192.png android-chrome-512x512.png site.webmanifest apple-touch-icon.png favicon-32x32.png favicon-16x16.png apple-developer-merchantid-domain-association)

  def router do
    quote do
      use Phoenix.Router, helpers: true

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: GitsWeb.Layouts]

      import Plug.Conn
      import GitsWeb.Gettext

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {GitsWeb.Layouts, :app}

      unquote(html_helpers())

      def ok(socket, false), do: {:ok, socket, layout: false}
      def ok(socket, layout), do: {:ok, socket, layout: {GitsWeb.Layouts, layout}}
      def ok(socket), do: {:ok, socket}
      def noreply(socket), do: {:noreply, socket}
    end
  end

  def host_live_view do
    quote do
      use Phoenix.LiveView,
        layout: {GitsWeb.Layouts, :host}

      unquote(html_helpers())

      def ok(socket, false), do: {:ok, socket, layout: false}
      def ok(socket, layout), do: {:ok, socket, layout: {GitsWeb.Layouts, layout}}
      def ok(socket), do: {:ok, socket}
      def noreply(socket), do: {:noreply, socket}
    end
  end

  def dashboard_live_view do
    quote do
      unquote(live_view())
      import GitsWeb.DashboardComponents

      require Ash.Query

      alias Gits.Dashboard.Member

      def mount(params, _session, socket) do
        user = socket.assigns.current_user

        {:ok, member} =
          Member
          |> Ash.Query.for_read(:read, %{}, actor: user)
          |> Ash.Query.filter(account.id == ^params["slug"])
          |> Ash.Query.filter(user.id == ^user.id)
          |> Ash.Query.load(:account)
          |> Ash.read_one()

        socket =
          socket
          |> assign(:slug, params["slug"])
          |> assign(:current_route, false)
          |> assign(:context_options, nil)
          |> assign(:accounts, [])
          |> assign(:account, member.account)

        {:ok, socket, layout: {GitsWeb.Layouts, :dashboard}}
      end
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())

      def ok(socket), do: {:ok, socket}
      def noreply(socket), do: {:noreply, socket}
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components and translation
      import GitsWeb.CoreComponents
      import GitsWeb.Gettext

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: GitsWeb.Endpoint,
        router: GitsWeb.Router,
        statics: GitsWeb.static_paths()

      alias GitsWeb.Router.Helpers, as: Routes
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
