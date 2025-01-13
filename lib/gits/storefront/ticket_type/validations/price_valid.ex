defmodule Gits.Storefront.TicketType.Validations.PriceValid do
  alias Ash.Error.Changes.InvalidAttribute
  use Ash.Resource.Validation

  def validate(changeset, opts, context) do
    price = Ash.Changeset.get_attribute(changeset, :price)

    case price do
      nil ->
        {:error, field: :price, message: "must be zero or greater than 50"}

      price ->
        if Decimal.eq?(price, Decimal.new(0)) or Decimal.gte?(price, Decimal.new(50)) do
          :ok
        else
          {:error, field: :price, message: "must be zero or greater than 50"}
        end
    end
  end

  def atomic(changeset, opts, context) do
    {:atomic, [:price], expr(^atomic_ref(:price) > 0 and ^atomic_ref(:price) < 50),
     expr(
       error(^InvalidAttribute, %{
         field: :price,
         value: ^atomic_ref(:price),
         message: ^(context.message || "%{field} must be zero or greater than 50"),
         vars: %{field: :price}
       })
     )}
  end
end
