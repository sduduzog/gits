defmodule GitsWeb.AuthGuard do
  import Phoenix.Controller

  def init(default), do: default

  def call(%{assigns: %{current_user: %Gits.Accounts.User{}}} = conn, _) do
    IO.puts("foooo")
    conn
  end

  def call(conn, _) do
    with %Gits.Accounts.User{} <- conn.assigns.current_user do
      render(conn, :settings)
    end

    return_to = conn |> current_path()

    conn
    |> redirect(to: "/sign-in?return_to=#{return_to}")
  end
end
