defmodule GitsWeb.MyLive.Settings do
  require Ash.Query
  alias Gits.Accounts.Host
  use GitsWeb, :live_view

  def mount(_, _, socket) do
    user = socket.assigns.current_user

    Host
    |> Ash.Query.filter(owner.id == ^user.id)
    |> Ash.read()
    |> case do
      {:ok, hosts} -> socket |> assign(:hosts, hosts)
    end
    |> assign(:uploaded_files, [])
    |> allow_upload(:logo, accept: ~w(.jpg .jpeg .png .webp), max_entries: 1)
    |> ok()
  end
end
