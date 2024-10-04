defmodule GitsWeb.DemoPricingCalculator do
  use GitsWeb, :live_view
  require Decimal

  def render(assigns) do
    ~H"""
    <div class="grid items-start gap-4 rounded-2xl">
      <h2 class="w-full text-right text-4xl font-semibold">Straighforward pricing</h2>

      <p class="max-w-80 ml-auto w-full text-right text-sm text-zinc-600">
        GiTS charges a single fee per transaction, avoiding per-ticket commission or service fees.
      </p>

      <form phx-change="validate" class="grid gap-2 py-20">
        <h3 class="col-span-full text-lg font-semibold">Try our order calculator</h3>
        <div class="grid-cols-[auto_auto] grid gap-4 lg:flex lg:items-start lg:justify-start lg:gap-8">
          <div class="col-span-full grid w-full gap-8 rounded-xl border p-4 lg:grid-cols-[theme(space.72)_theme(space.40)_theme(space.64)] lg:w-auto lg:gap-4">
            <div class="col-span-full grid gap-2 lg:col-auto">
              <span class="font-semibold">Price Per Ticket</span>
              <div class="flex font-medium">
                <span class="text-base">R</span>
                <span class="text-5xl"><%= @price %></span>
              </div>
              <input
                name="price"
                type="range"
                min="0"
                max="2000"
                value={@price}
                step="50"
                class="w-full accent-zinc-900"
              />
            </div>

            <div class="grid w-full gap-2">
              <span class="font-semibold">Tickets Count</span>
              <div class="flex font-medium">
                <span class="text-5xl"><%= @count %></span>
              </div>
              <input
                name="count"
                type="range"
                min="1"
                max="10"
                value={@count}
                step="1"
                class="w-full accent-zinc-900"
              />
            </div>

            <div class="grid w-full gap-2">
              <span class="font-semibold">The customer pays</span>
              <div class="flex font-medium">
                <span class="text-base">R</span>
                <span class="text-5xl"><%= @results.total_price %></span>
              </div>
              <input
                disabled
                name="count"
                type="range"
                min="1"
                max="10"
                value={@count}
                step="1"
                class="w-full accent-zinc-900 opacity-0"
              />
            </div>
          </div>

          <div class="grid shrink-0 grow gap-2 lg:max-w-64 lg:mt-4">
            <span>What you get</span>
            <div class="flex font-medium">
              <span class="text-sm">R</span>
              <span class="text-4xl"><%= @results.theirs %></span>
            </div>
          </div>

          <div class="grid shrink-0 grow gap-2 lg:max-w-40 lg:mt-4">
            <span class="self-end text-right">Transaction cost</span>
            <div class="flex justify-end font-medium">
              <span class="text-sm">R</span>
              <span class="text-4xl"><%= @results.ours %></span>
            </div>
          </div>
        </div>
      </form>
      <div class="flex justify-end gap-2">
        <span>No setup costs</span>
        <.icon name="hero-check-circle" class="size-5" />
      </div>

      <div class="flex justify-end gap-2">
        <span>5% per transaction</span>
        <.icon name="hero-check-circle" class="size-5" />
      </div>

      <div class="flex justify-end gap-2">
        <span>Comprehensive sales analytics</span>
        <.icon name="hero-check-circle" class="size-5" />
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    price = "50"
    count = "1"

    socket
    |> assign(:price, price)
    |> assign(:count, count)
    |> assign(:results, calculate_results(price, count))
    |> ok(false)
  end

  def handle_event("validate", %{"price" => price, "count" => count}, socket) do
    socket
    |> assign(:price, price)
    |> assign(:count, count)
    |> assign(:results, calculate_results(price, count))
    |> noreply()
  end

  defp calculate_results(price, count) do
    price = price |> Decimal.new()
    count = count |> Decimal.new()

    total_price = price |> Decimal.mult(count)

    our_cut = total_price |> Decimal.mult(Decimal.new("0.05"))

    their_cut = total_price |> Decimal.sub(our_cut)

    %{
      ours: our_cut |> Gits.Currency.format(),
      theirs: their_cut |> Gits.Currency.format(),
      total_price: total_price |> Decimal.round()
    }
  end
end
