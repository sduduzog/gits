defmodule Gits.Storefront.TicketType.Fragments.Calculations do
  use Spark.Dsl.Fragment, of: Ash.Resource

  calculations do
    calculate :utc_sale_starts_at,
              :utc_datetime,
              expr(fragment("? at time zone (?)", sale_starts_at, "Africa/Johannesburg"))

    calculate :utc_sale_ends_at,
              :utc_datetime,
              expr(fragment("? at time zone (?)", sale_ends_at, "Africa/Johannesburg"))

    calculate :sale_started?, :boolean, expr(utc_sale_starts_at < fragment("now()"))
    calculate :sale_ended?, :boolean, expr(utc_sale_ends_at < fragment("now()"))
    calculate :on_sale?, :boolean, expr(sale_started? and not sale_ended?)

    calculate :sold_out, :boolean, expr(valid_tickets_count == quantity)

    calculate :limit_reached,
              :boolean,
              expr(
                count(tickets,
                  query: [
                    filter: expr(state != :released and order.email == ^arg(:email))
                  ]
                ) ==
                  limit_per_user
              ) do
      argument :email, :ci_string
    end
  end
end
