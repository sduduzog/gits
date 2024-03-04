defmodule Gits.Accounts.User.Notifiers.UserCreated do
  use Ash.Notifier

  def notify(notification) do
    IO.inspect(notification)
  end
end
