defmodule Gits.Storefront.EventCategory do
  use Ash.Type.Enum,
    values: [
      other: "Other",
      wedding: "Wedding",
      birthday_party: "Birthday Party",
      anniversay_celebration: "Anniversary Celebration",
      concert: "Concert",
      conference: "Conference",
      serminar: "Seminar",
      workshop: "Workshop",
      exhibition: "Exhibition",
      parade: "Parade",
      public_lecture: "Public Lecture",
      festival: "Festival",
      carnival: "Carnival",
      theatre_production: "Theatre Production",
      religious_celebration: "Religious Celebration",
      sport: "Sport",
      fitness: "Fitness",
      charity: "Charity",
      political_rally: "Political Rally",
      town_hall: "Town Hall",
      meetup: "Meetup"
    ]
end
