defmodule Gits.Storefront.EventCategory do
  use Ash.Type.Enum,
    values: [
      wedding: "",
      birthday_party: "",
      anniversay_celebration: "",
      concert: "",
      conference: "",
      serminar: "",
      workshop: "",
      exhibition: "",
      parade: "",
      public_lecture: "",
      festival: "",
      carnival: "",
      theatre_production: "",
      religious_celebration: "",
      sport: "",
      fitness: "",
      charity: "",
      political_rally: "",
      town_hall: "",
      meetup: ""
    ]
end
