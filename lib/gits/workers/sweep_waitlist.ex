defmodule Gits.Workers.SweepWaitlist do
  require Ash.Query
  alias Gits.Dashboard.Account
  alias Gits.Dashboard.Member
  use Oban.Worker

  @impl Oban.Worker
  def perform(job) do
    members =
      Member
      |> Ash.Query.for_read(:read, %{}, actor: job)
      |> Ash.Query.filter(state == :waitlisted)
      |> Ash.Query.load(:user)
      |> Ash.read!()

    Enum.each(members, fn member ->
      Account
      |> Ash.Changeset.for_create(
        :create_from_waitlist,
        %{member: member, name: member.user.display_name},
        actor: job
      )
      |> Ash.create!()
    end)
  end
end
