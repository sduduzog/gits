defmodule Gits.Storefront.Event.Fragments.Actions do
  use Spark.Dsl.Fragment,
    of: Ash.Resource,
    extensions: [AshStateMachine]

  actions do
    defaults [:read, :destroy, update: :*]

    read :get_by_public_id_for_listing do
      get_by [:public_id]
      prepare build(load: [:name])
    end

    read :archived do
      filter expr(not is_nil(archived_at))
    end

    create :create do
      primary? true
      accept [:name, :starts_at, :ends_at, :visibility]

      argument :host, :map
      argument :poster, :map
      argument :venue, :map

      change manage_relationship(:host, type: :append)
      change manage_relationship(:poster, type: :append)
      change manage_relationship(:venue, type: :append)
    end

    update :details do
      require_atomic? false
      accept :*

      argument :poster, :map
      argument :venue, :map

      change manage_relationship(:poster,
               on_lookup: :relate,
               on_missing: :unrelate,
               on_no_match: :error
             )

      change manage_relationship(:venue, type: :append)
    end

    update :sort_ticket_types do
      require_atomic? false

      argument :ticket_types, {:array, :map}
      change manage_relationship(:ticket_types, on_match: {:update, :order})
    end

    update :location do
      accept [:location_notes, :location_is_private]
    end

    update :create_venue do
      require_atomic? false

      argument :venue, :map, allow_nil?: false
      change manage_relationship(:venue, type: :create)
    end

    update :use_venue do
      require_atomic? false

      argument :venue, :uuid, allow_nil?: false
      change manage_relationship(:venue, type: :append)
    end

    update :remove_venue do
      require_atomic? false

      argument :venue, :uuid, allow_nil?: false
      change manage_relationship(:venue, type: :remove)
    end

    update :description do
      accept [:summary, :description]
    end

    update :publish do
      change atomic_update(:published_at, expr(fragment("now()")))
      change transition_state(:published)
    end

    update :add_ticket_type do
      require_atomic? false
      argument :type, :map, allow_nil?: false
      change manage_relationship(:type, :ticket_types, type: :create)
    end

    update :edit_ticket_type do
      require_atomic? false
      argument :type, :map, allow_nil?: false
      change manage_relationship(:type, :ticket_types, on_match: :update)
    end

    update :archive_ticket_type do
      require_atomic? false
      argument :type, :map, allow_nil?: false
      change manage_relationship(:type, :ticket_types, on_match: :destroy)
    end

    update :create_order do
      require_atomic? false

      argument :order, :map, allow_nil?: false
      change manage_relationship(:order, :orders, type: :create)
    end

    update :complete do
      change atomic_update(:completed_at, expr(fragment("now()")))
      change transition_state(:completed)
    end
  end
end
