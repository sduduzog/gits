defmodule GitsWeb.AdminLive.Index do
  alias Gits.Storefront.Event
  alias Gits.Accounts.Host
  alias Gits.Support.Job
  use GitsWeb, :live_view

  def mount(_, _, socket) do
    socket |> ok(false)
  end

  def handle_params(_, _, socket) do
    user = Ash.load!(socket.assigns.current_user, [:admin])

    socket = assign(socket, :current_user, user)

    case socket.assigns.live_action do
      :jobs ->
        Ash.Query.for_read(Job, :read)
        |> Ash.Query.sort(id: :desc)
        |> Ash.read(actor: user)
        |> case do
          {:ok, jobs} ->
            socket
            |> assign(:jobs, jobs)
            |> noreply()
        end

      :hosts ->
        Ash.Query.for_read(Host, :read)
        |> Ash.Query.load([:owner, :paystack_business_name])
        |> Ash.read(actor: user)
        |> case do
          {:ok, hosts} ->
            socket
            |> assign(:hosts, hosts)
            |> noreply()
        end

      :events ->
        # calculations do
        #     calculate :published?, :boolean, expr(not is_nil(published_at))
        #
        #     calculate :utc_starts_at,
        #               :utc_datetime,
        #               expr(fragment("? at time zone (?)", starts_at, "Africa/Johannesburg"))
        #
        #     calculate :utc_ends_at,
        #               :utc_datetime,
        #               expr(fragment("? at time zone (?)", ends_at, "Africa/Johannesburg"))
        #
        #     calculate :start_date_invalid?, :boolean, expr(utc_starts_at < fragment("now()"))
        #     calculate :end_date_invalid?, :boolean, expr(utc_ends_at < utc_starts_at)
        #     calculate :venue_invalid?, :boolean, expr(is_nil(venue))
        #
        #     calculate :ticket_prices_vary?, :boolean, expr(minimum_ticket_price != maximum_ticket_price)
        #   end
        #
        #   aggregates do
        #     count :unique_views, :interactions do
        #       field :viewer_id
        #       uniq? true
        #     end
        #
        #     count :total_orders, :orders do
        #       filter state: :completed
        #     end
        #
        #     count :admissions, [:ticket_types, :tickets] do
        #       join_filter [:ticket_types, :tickets], expr(not is_nil(admitted_at))
        #     end
        #
        #     min :minimum_ticket_price, :ticket_types, :price, default: Decimal.new(0)
        #     max :maximum_ticket_price, :ticket_types, :price, default: Decimal.new(0)
        #
        #     sum :total_revenue, :orders, :total, default: Decimal.new(0)
        #
        #     sum :actual_revenue, [:orders, :fees_split], :subaccount, default: Decimal.new(0)
        #   end

        Ash.Query.for_read(Event, :read)
        |> Ash.Query.load([
          :published?,
          :unique_views,
          :total_orders,
          :minimum_ticket_price,
          :maximum_ticket_price
        ])
        |> Ash.read(actor: user)
        |> case do
          {:ok, events} ->
            socket
            |> assign(:events, events)
            |> noreply()
        end

      _ ->
        socket |> noreply()
    end
  end

  def handle_event("retry-job", unsigned_params, socket) do
    Oban.retry_job(unsigned_params["id"] |> String.to_integer())

    user = socket.assigns.current_user

    Ash.Query.for_read(Job, :read)
    |> Ash.Query.sort(id: :desc)
    |> Ash.read(actor: user)
    |> case do
      {:ok, jobs} ->
        socket
        |> assign(:jobs, jobs)
        |> noreply()
    end
  end

  def handle_event("cancel-job", unsigned_params, socket) do
    Oban.cancel_job(unsigned_params["id"] |> String.to_integer())

    user = socket.assigns.current_user

    Ash.Query.for_read(Job, :read)
    |> Ash.Query.sort(id: :desc)
    |> Ash.read(actor: user)
    |> case do
      {:ok, jobs} ->
        socket
        |> assign(:jobs, jobs)
        |> noreply()
    end
  end
end
