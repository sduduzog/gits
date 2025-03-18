defmodule Gits.Oban.Workers.SendHostInviteEmail do
  require Decimal
  use Oban.Worker, max_attempts: 1

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
  end
end
