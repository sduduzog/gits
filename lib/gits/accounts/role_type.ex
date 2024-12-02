defmodule Gits.Accounts.RoleType do
  use Ash.Type.Enum,
    values: [admin: "The administrator", support: "", manager: "", security: "", operations: ""]
end
