defmodule GitsWeb.AuthLive do
  use GitsWeb, :live_view

  alias Gits.Accounts
  alias Gits.Accounts.User
  alias AshPhoenix.Form

  def mount(_, session, socket) do
    IO.inspect(session)
    remote_ip = get_connect_info(socket, :peer_data).address

    socket =
      socket
      |> assign(:remote_ip, remote_ip)
      |> apply_action(:sign_in)

    {:ok, socket, layout: false}
  end

  # defp apply_action(socket, :register) do
  #   socket
  #   |> assign(page_title: "Sign Up")
  #   |> assign(:form_id, "sign-up-form")
  #   |> assign(:cta, "Sign up")
  #   |> assign(:alternative_path, ~p"/sign-in")
  #   |> assign(:alternative, "Have an account?")
  #   |> assign(:action, ~p"/auth/user/password/register")
  #   |> assign(
  #     :form,
  #     Form.for_create(User, :register_with_password, api: Accounts, as: "user")
  #   )
  # end

  defp apply_action(socket, :sign_in) do
    socket
    |> assign(:form_id, "sign-in-form")
    |> assign(:cta, "Sign in")
    |> assign(:alternative_path, ~p"/register")
    |> assign(:alternative, "Need an account?")
    |> assign(:action, ~p"/auth/user/password/sign_in")
    |> assign(
      :form,
      Form.for_action(User, :sign_in_with_password, api: Accounts, as: "user")
    )
  end

  def render(assigns) do
    ~H"""
    <div>form</div>
    """
  end

  def rendered(assigns) do
    ~H"""
    <.live_component
      module={GitsWeb.AuthLive.AuthForm}
      id={@form_id}
      form={@form}
      is_register?={@live_action == :register}
      action={@action}
      cta={@cta}
      remote_ip={@remote_ip}
    />

    <p class="px-6 md:px-12">
      <.link navigate={@alternative_path}><%= @alternative %></.link>
    </p>
    """
  end
end
