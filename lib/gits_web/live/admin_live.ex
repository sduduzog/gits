defmodule GitsWeb.AdminLive do
  require Ash.Query
  alias Gits.Accounts.Host
  alias Gits.Support.Admin
  use GitsWeb, :live_view

  def mount(_params, _session, socket) do
    navigation = [
      # {"Home", "ri--home-line", ~p"/hosts/#{host.handle}/dashboard",
      #  Enum.any?([Dashboard], &(&1 == view)), [], nil},
      # {"Events", "ri--calendar-line", ~p"/hosts/#{host.handle}/events",
      #  Enum.any?([Events], &(&1 == view)), [], nil},
      # {"Team", "ri--team-line", false, Enum.any?([Settings], &(&1 == view)), [], nil},
      # {"Settings", "ri--settings-3-line", false, Enum.any?([Settings], &(&1 == view)),
      #  [
      #    # {"General", "", false},
      #    # {"Members", "", false},
      #    # {"Billing", "", false},
      #    {"API", ~p"/hosts/#{host.handle}/settings/api", live_action == :api, nil}
      #  ], nil}
    ]

    socket
    |> assign(:navigation_items, navigation)
    |> ok(:dashboard)
  end

  def handle_params(_unsigned_params, _uri, socket) do
    user = socket.assigns.current_user

    case socket.assigns.live_action do
      :start ->
        Ash.Query.for_read(Admin, :read)
        |> Ash.count(actor: socket.assigns.current_user)
        |> case do
          {:ok, 0} ->
            Ash.Changeset.for_create(Admin, :create, %{user: socket.assigns.current_user},
              actor: socket.assigns.current_user
            )
            |> Ash.create()

            socket

          _ ->
            socket
        end
        |> push_patch(to: Routes.admin_index_path(socket, :dashboard))
        |> noreply()

      _ ->
        hosts =
          Ash.read!(Host, actor: user)

        socket
        |> assign(:hosts, hosts)
        |> noreply()
    end
  end

  def handle_event("verify", unsigned_params, socket) do
    Ash.Query.filter(Host, id == ^unsigned_params["id"])
    |> Ash.bulk_update(:verify, %{}, actor: socket.assigns.current_user)

    hosts =
      Ash.read!(Host, actor: socket.assigns.current_user)

    socket
    |> assign(:hosts, hosts)
    |> noreply()
  end
end
