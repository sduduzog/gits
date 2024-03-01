defmodule GitsWeb.AuthLive.Index do
  use GitsWeb, :live_view
  alias Gits.Accounts
  alias Gits.Accounts.User
  alias AshPhoenix.Form

  def mount(_, _, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :register, _params) do
    socket
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
      <h1 class="mt-6 text-center text-2xl font-bold leading-9 tracking-tight text-gray-900">
        <%= @cta %>
      </h1>

      <div class="p-12 bg-white rounded-lg shadow">
        <.live_component
          module={GitsWeb.AuthLive.AuthForm}
          id={@form_id}
          form={@form}
          is_register?={@live_action == :register}
          action={@action}
          cta={@cta}
        />
      </div>

      <p class="">
        <.link patch={@alternative_path}><%= @alternative %></.link>
      </p>
    </div>
    """
  end
end
