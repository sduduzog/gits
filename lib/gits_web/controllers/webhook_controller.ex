defmodule GitsWeb.WebhookController do
  require Decimal
  require Ash.Query
  alias Gits.Storefront.Order
  use GitsWeb, :controller

  defp valid_paystack_request?(conn) do
    secret_key = Application.get_env(:gits, :paystack) |> Keyword.get(:secret_key)
    [signature] = get_req_header(conn, "x-paystack-signature")

    hash =
      :crypto.mac(:hmac, :sha512, secret_key, conn.assigns.raw_body)
      |> Base.encode16(case: :lower)

    signature == hash
  end

  defp from_cents(amount) when is_integer(amount), do: Decimal.new(amount) |> from_cents()
  defp from_cents(amount) when is_float(amount), do: Decimal.from_float(amount) |> from_cents()
  defp from_cents(amount), do: Decimal.div(amount, 100)

  def paystack(conn, %{"event" => "charge.success"} = params) do
    if valid_paystack_request?(conn) do
      data = params["data"]

      fees_split =
        data["fees_split"]

      reference = data["reference"]

      Ash.Query.filter(Order, paystack_reference == ^reference)
      |> Ash.read_one()
      |> case do
        {:ok, nil} ->
          put_status(conn, 200)
          |> text("OK")

        {:ok, order} ->
          Ash.Changeset.for_update(order, :complete, %{
            fees_split: %{
              integration: fees_split["integration"] |> from_cents(),
              paystack: fees_split["paystack"] |> from_cents(),
              subaccount: fees_split["subaccount"] |> from_cents()
            }
          })
          |> Ash.update()

          put_status(conn, 200)
          |> text("OK")
      end
    else
      put_status(conn, 403)
      |> text("Forbidden")
    end
  end

  # def paystack(_conn, %{"event" => "refund.processed"} = _params) do
  #   refund = %{
  #     "data" => %{
  #       "amount" => 15067,
  #       "currency" => "ZAR",
  #       "customer" => %{
  #         "email" => "foo@bar.com",
  #         "first_name" => nil,
  #         "last_name" => nil
  #       },
  #       "customer_note" => "Refund for transaction jonh9ps4xl",
  #       "domain" => "test",
  #       "id" => "13379479",
  #       "integration" => 1_189_131,
  #       "merchant_note" => "Refund for transaction jonh9ps4xl by gumedesduduzo@gmail.com",
  #       "refund_reference" => nil,
  #       "status" => "processed",
  #       "transaction_reference" => "jonh9ps4xl"
  #     },
  #     "event" => "refund.processed"
  #   }
  # end
end
