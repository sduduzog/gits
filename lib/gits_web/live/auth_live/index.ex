defmodule GitsWeb.AuthLive.Index do
  use GitsWeb, :live_view
  alias Gits.Accounts
  alias Gits.Accounts.User
  alias AshPhoenix.Form

  def mount(_, _, socket) do
    remote_ip = get_connect_info(socket, :peer_data).address
    {:ok, assign(socket, :remote_ip, remote_ip)}
  end

  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :register, _params) do
    socket
    |> assign(page_title: "Sign Up")
    |> assign(:form_id, "sign-up-form")
    |> assign(:cta, "Sign up")
    |> assign(:alternative_path, ~p"/sign-in")
    |> assign(:alternative, "Have an account?")
    |> assign(:action, ~p"/auth/user/password/register")
    |> assign(
      :form,
      Form.for_create(User, :register_with_password, api: Accounts, as: "user")
    )
  end

  defp apply_action(socket, :sign_in, _params) do
    socket
    |> assign(:form_id, "sign-in-form")
    |> assign(page_title: "Sign In")
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
    <div class="mx-auto max-w-lg space-y-6">
      <span class="pt-6 lg:pt-20 block text-center font-black italic font-poppins text-2xl text-gray-900/50">
        <.link navigate={~p"/"}>GiTS</.link>
      </span>
      <h1 class="mt-6 text-center text-2xl font-bold leading-9 tracking-tight text-gray-900">
        <%= @cta %>
      </h1>

      <div class="md:p-12 p-6 bg-white md:rounded-lg shadow">
        <.live_component
          module={GitsWeb.AuthLive.AuthForm}
          id={@form_id}
          form={@form}
          is_register?={@live_action == :register}
          action={@action}
          cta={@cta}
          remote_ip={@remote_ip}
        />
      </div>

      <p class="px-6 md:px-12">
        <.link navigate={@alternative_path}><%= @alternative %></.link>
      </p>
    </div>
    """
  end
end
