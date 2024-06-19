defmodule Gits.Dashboard.Changes.UpdatePaystackSubaccount do
  use Ash.Resource.Change

  def change(changeset, _opts, %{actor: _actor}) do
    changeset
    |> Ash.Changeset.before_action(fn changeset ->
      if changeset.data.paystack_subaccount_code do
        Gits.PaystackApi.update_subaccount(
          changeset.data.paystack_subaccount_code,
          Ash.Changeset.get_argument(changeset, :business_name),
          Ash.Changeset.get_argument(changeset, :account_number),
          Ash.Changeset.get_argument(changeset, :settlement_bank)
        )
      else
        Gits.PaystackApi.create_subaccount(
          Ash.Changeset.get_argument(changeset, :business_name),
          Ash.Changeset.get_argument(changeset, :account_number),
          Ash.Changeset.get_argument(changeset, :settlement_bank)
        )
      end
      |> case do
        {:ok, subaccount} ->
          Ash.Changeset.change_new_attribute(
            changeset,
            :paystack_subaccount_code,
            subaccount.subaccount_code
          )

        _ ->
          Ash.Changeset.add_error(changeset,
            field: :paystack_subaccount_code,
            message: "couldn't create or update subaccount"
          )
      end
    end)
  end
end
