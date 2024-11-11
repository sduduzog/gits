defmodule Gits.Accounts.User.Senders.SendMagicLinkEmail do
  import Swoosh.Email
  use AshAuthentication.Sender
  alias __MODULE__.Worker

  @impl true
  def send(user_or_email, token, _) do
    email =
      case user_or_email do
        %{email: email} -> email |> to_string()
        email -> email
      end

    %{email: email, token: token}
    |> Worker.new()
    |> Oban.insert()
  end
end

defmodule Gits.Accounts.User.Senders.SendMagicLinkEmail.Worker do
  use Oban.Worker, max_attempts: 1

  import Swoosh.Email

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"email" => email, "token" => token}}) do
    [sender: sender] =
      Application.get_env(:gits, :email)

    new()
    |> to(email)
    |> from(sender)
    |> text_body("""
    Welcome to GiTS

    To finish signing in, use the following url bellow:

    #{"/auth/user/magic_link?token=#{token}"}
    """)
    |> put_provider_option(:custom_vars, %{"url" => "/auth/user/magic_link/?token=#{token}"})
    |> put_provider_option(:template_name, "magic-link")
    |> put_provider_option(:template_options, %{version: "initial"})
    |> IO.inspect()
    |> Gits.Mailer.deliver()
  end
end
