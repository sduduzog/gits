defmodule Gits.Accounts.RoleType do
  use Ash.Type.Enum,
    values: [
      owner: "The owner of the organization. Has admin level access",
      admin: "The administrator",
      support: "",
      manager: "",
      security: "",
      operations: ""
    ]
end
