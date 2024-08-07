defmodule Gits.Storefront.Changes.StartPaystackTransaction do
  require Decimal
  use GitsWeb, :verified_routes
  use Ash.Resource.Change

  alias Gits.PaystackApi

  def change(changeset, _opts, %{actor: user} = _context) do
    changeset
    |> Ash.Changeset.before_action(fn changeset ->
      basket =
        changeset.data
        |> Ash.load!([event: [:masked_id, :account]], actor: user)

      subaccount_code =
        basket.event.account.paystack_subaccount_code

      email =
        user.email
        |> to_string

      amount =
        basket.total
        |> Decimal.mult(100)
        |> Decimal.to_integer()
        |> to_string()

      callback_url = url(~p"/events/#{basket.event.masked_id}?basket=#{basket.id}")

      {:ok, transaction} =
        PaystackApi.create_transaction(
          subaccount_code,
          email,
          amount,
          callback_url
        )

      changeset
      |> Ash.Changeset.change_attributes(%{
        paystack_authorization_url: transaction.authorization_url,
        paystack_reference: transaction.reference
      })
    end)
  end
end
