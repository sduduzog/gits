defmodule Gits do
  @moduledoc """
  Gits keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def role_to_readable_string(role) do
    case role do
      :owner -> "Owner"
      :admin -> "Admin"
      :sales_manager -> "Sales Manager"
    end
  end
end
