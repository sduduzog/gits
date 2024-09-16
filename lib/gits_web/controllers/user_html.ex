defmodule GitsWeb.UserHTML do
  alias Gits.Storefront.Event
  use GitsWeb, :html

  embed_templates "user_html/*"

  def ticket_dates_from_event(%Event{local_starts_at: starts_at, local_ends_at: ends_at}) do
    "#{starts_at |> format_datetime()} - #{ends_at |> format_end_date(starts_at)}"
  end

  defp format_time(starts_at) do
    starts_at |> Timex.format!("%I:%M %p", :strftime)
  end

  defp format_datetime(starts_at) do
    starts_at |> Timex.format!("%e %b, %Y, %I:%M %p", :strftime)
  end

  defp format_end_date(ends_at, starts_at) do
    starts_at
    |> NaiveDateTime.diff(ends_at, :day)
    |> case do
      0 ->
        ends_at |> format_time()

      _ ->
        ends_at |> format_datetime()
    end
  end
end
