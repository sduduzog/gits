defmodule GitsWeb.SearchHTML do
  use GitsWeb, :html
  require Decimal
  alias Gits.Storefront.Event

  def index(assigns) do
    ~H"""
    <.form :let={f} for={%{}} method="get" class="p-2 w-full">
      <div class="mx-auto flex w-full max-w-screen-md items-center gap-3 overflow-hidden rounded-xl border pl-3">
        <.icon name="hero-magnifying-glass-micro" />
        <input class="grow py-3 pr-3 text-sm focus:outline-none" name={f[:query].name} />
      </div>
    </.form>
    <!-- <h1 class="mt-8 p-2 text-4xl font-light">Events</h1> -->
    <div class="mt-8 grid w-full gap-8 overflow-hidden p-2 lg:grid-cols-3 lg:gap-4">
      <.link
        :for={event <- @events}
        navigate={~p"/events/#{event.masked_id}"}
        class="flex items-center gap-2 lg:p-2 lg:border dark:border-zinc-600 rounded-xl hover:bg-zinc-50 hover:dark:bg-zinc-800"
      >
        <div class="aspect-[3/2] w-24 shrink-0 overflow-hidden rounded-lg">
          <img
            loading="eager"
            src={Gits.Bucket.get_feature_image_path(event.account_id, event.id)}
            alt=""
            class="size-full object-cover transition-transform duration-300 ease-in-out group-hover:scale-110"
          />
        </div>
        <div class="grid gap-0.5">
          <div class="inline-flex items-center gap-1">
            <span class="max-w-40 truncate text-xs font-medium">
              <%= if not is_nil(event.address) do %>
                <%= event.address.display_name %>
              <% else %>
                n/a
              <% end %>
            </span>
            <span class="text-xs">
              &bull;
            </span>
            <span class="shrink-0 text-xs font-medium">
              <%= event.starts_at |> Timex.format!("%a, %e %b, %I:%M%p", :strftime) %>
            </span>
          </div>
          <span class="truncate text-lg font-medium"><%= event.name %></span>
          <span
            :if={not is_nil(event.minimum_ticket_price)}
            class="whitespace-nowrap text-xs font-medium text-zinc-500 dark:text-zinc-400"
          >
            <%= resolve_price_range_label(event) %>
          </span>
        </div>
      </.link>
    </div>
    """
  end

  def get_listing_image(account_id, event_id) do
    Gits.Bucket.get_listing_image_path(account_id, event_id)
  end

  defp resolve_min_price_label(price) do
    if Decimal.eq?(price, 0) do
      "FREE"
    else
      "R#{price |> Gits.Currency.format()}"
    end
  end

  defp resolve_price_summary_label(%Event{minimum_ticket_price: min, maximum_ticket_price: max}) do
    if min == max do
      "#{resolve_min_price_label(min)}"
    else
      "#{resolve_min_price_label(min)}+"
    end
  end

  defp resolve_price_range_label(%Event{minimum_ticket_price: min, maximum_ticket_price: max}) do
    if min == max do
      "#{resolve_min_price_label(min)}"
    else
      "#{resolve_min_price_label(min)} - R#{max |> Gits.Currency.format()}"
    end
  end
end
