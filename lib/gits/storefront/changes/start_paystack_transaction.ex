defmodule Gits.Storefront.Changes.StartPaystackTransaction do
  require Decimal
  use Ash.Resource.Change

  alias Gits.PaystackApi

  def change(changeset, _opts, %{actor: user} = _context) do
    changeset
    |> Ash.Changeset.before_action(fn changeset ->
      basket =
        changeset.data
        |> Ash.load!([event: [:account]], actor: user)

      subaccount_code =
        basket.event.account.paystack_subaccount_code

      email =
        user.email
        |> to_string

      amount =
        basket.sum_of_instance_prices
        |> Decimal.mult(100)
        |> Decimal.to_integer()
        |> to_string()

      {:ok, transaction} =
        PaystackApi.create_transaction(
          subaccount_code,
          email,
          amount
        )

      changeset
      |> Ash.Changeset.change_attributes(%{
        paystack_authorization_url: transaction.authorization_url,
        paystack_reference: transaction.reference
      })
    end)
  end
end
