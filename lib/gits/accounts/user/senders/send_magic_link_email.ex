defmodule Gits.Accounts.User.Senders.SendMagicLinkEmail do
  use AshAuthentication.Sender
  use Oban.Worker, max_attempts: 1

  @impl true
  def send(user_or_email, token, _) do
    email =
      case user_or_email do
        %{email: email} -> email |> to_string()
        email -> email
      end

    %{email: email, token: token}
    |> __MODULE__.new()
    |> Oban.insert()
    |> case do
      {:ok, _} -> :ok
      _ -> :error
    end
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"email" => email, "token" => token}}) do
    Gits.Mailer.magic_link(token, email)
  end
end
