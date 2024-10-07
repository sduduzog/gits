defmodule GitsWeb.HostLive.ManageEventComponents do
  use Phoenix.Component
  use GitsWeb, :verified_routes

  import GitsWeb.CoreComponents
  # alias Phoenix.LiveView.JS

  def onboarding_step_form(%{current: :create_event} = assigns) do
    ~H"""
    <div class="grid grid-cols-2 gap-6 pt-4">
      <div class="col-span-full space-y-2">
        <p class=" text-zinc-700 pb-4">
          Please set up your host account to start creating and managing your events. Once completed, you’ll be directed to the event creation form.
        </p>
        <label class="col-span-full grid gap-1">
          <span class="text-sm font-medium">Host name</span>
          <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
        </label>

        <label class="col-span-full grid gap-1">
          <div class="flex items-center rounded-lg border border-zinc-300 pl-3">
            <span class="text-sm text-zinc-500">gits.co.za/hosts/</span>
            <input
              type="text"
              value="This is a very long value placeholder"
              class="w-full rounded-lg border-none py-2 pl-0 pr-3 text-sm focus-visible:ring-0"
            />
            <.icon :if={false} name="hero-check-micro" class="shrink-0 mr-3" />
            <.icon name="hero-arrow-path-micro" class="shrink-0 animate-spin text-zinc-400 mr-3" />
          </div>
        </label>
      </div>

      <div class="col-span-full grid grid-cols-[auto_1fr] items-center gap-1 gap-x-4">
        <span class="col-span-full w-full text-sm font-medium">Upload the host logo</span>
        <div class="aspect-square w-24 rounded-xl bg-zinc-200"></div>
        <div class="inline-grid">
          <label class="inline-flex">
            <span class="sr-only">Choose logo</span>
            <input
              type="file"
              class="w-full text-sm font-medium file:mr-4 file:h-9 file:rounded-lg file:border file:border-solid file:border-zinc-300 file:bg-white file:px-4 file:py-2 hover:file:bg-zinc-50"
            />
          </label>
        </div>
      </div>

      <label class="col-span-full grid gap-1">
        <span class="text-sm font-medium">What is the name of your event?</span>
        <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
      </label>

      <label class="col-span-full grid gap-1">
        <span class="text-sm font-medium">Describe the event?</span>
        <textarea rows="5" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm"></textarea>
      </label>

      <fieldset class="col-span-full grid gap-4 lg:grid-cols-2 lg:gap-6">
        <legend class="col-span-full inline-flex text-sm font-medium">
          Event visibility
        </legend>

        <label class="mt-1 flex gap-2 rounded-lg border px-3 py-2 has-[:checked]:ring-2 has-[:checked]:ring-zinc-600">
          <input type="radio" name="event-location" checked class="peer sr-only" />
          <div class="grid grow gap-1">
            <span class="text-sm font-medium text-zinc-950">Private</span>
            <span class="text-sm text-zinc-500">
              Only people with the link to the event will be able to see it
            </span>
          </div>
          <.icon
            name="hero-check-circle-mini"
            class="shrink-0 text-zinc-700 opacity-0 peer-checked:opacity-100"
          />
        </label>

        <label class="mt-1 flex gap-2 rounded-lg border px-3 py-2 has-[:disabled]:opacity-60 has-[:checked]:ring-2 has-[:checked]:ring-zinc-600">
          <input type="radio" name="event-location" class="peer sr-only" />
          <div class="grid grow gap-1">
            <span class="text-sm font-medium text-zinc-950">Public</span>
            <span class="text-sm text-zinc-500">
              The event will be publicly discoverable on the platform
            </span>
          </div>
          <.icon
            name="hero-check-circle-mini"
            class="shrink-0 text-zinc-700 opacity-0 peer-checked:opacity-100"
          />
        </label>
      </fieldset>

      <div class="col-span-full flex justify-end gap-6">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  def onboarding_step_form(%{current: :time_and_place} = assigns) do
    ~H"""
    <div class="grid grid-cols-2 gap-4 gap-y-6 pt-4 lg:gap-6">
      <label class="grid gap-1">
        <span class="text-sm font-medium">Start date</span>
        <input type="datetime-local" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
      </label>

      <label class="grid gap-1">
        <span class="text-sm font-medium">End date</span>
        <input type="datetime-local" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
      </label>

      <div class="relative col-span-full grid gap-1">
        <div class="flex items-center gap-2">
          <span class="text-sm font-medium">Venue</span>
          <span class="hidden text-sm">
            &bull;
          </span>
        </div>
        <div class="flex items-start gap-4 lg:gap-6">
          <div class="grow rounded-lg border border-zinc-300 p-2 px-3">
            <div class="flex items-start gap-2">
              <.icon name="hero-map-pin" class="size-5 shrink-0 text-zinc-500" />
              <span class="text-sm">
                No venue chosen
              </span>
            </div>
          </div>
          <button class="inline-flex size-9 shrink-0 items-center justify-center rounded-lg border border-zinc-300">
            <.icon name="hero-magnifying-glass-mini" class="size-5x" />
          </button>
        </div>
        <span class="text-xs text-zinc-500">Status: pending approval</span>
      </div>

      <label :if={false} for="" class="grid gap-1">
        <span class="text-sm font-medium">Venue</span>
        <input type="datetime-local" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
      </label>

      <div class="col-span-full flex justify-end gap-6">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  def onboarding_step_form(%{current: :upload_feature_graphic} = assigns) do
    ~H"""
    <div class="grid grid-cols-2 gap-6 pt-4">
      <fieldset class="col-span-full grid gap-4 lg:grid-cols-2">
        <legend class="col-span-full inline-flex text-sm font-medium">
          Upload a feature graphic
        </legend>

        <div class="relative col-span-full mt-1 flex aspect-[3/2] flex-col items-center justify-center gap-2 rounded-2xl border-2 border-dashed">
          <span class="text-sm text-zinc-600">
            <label class="has-[:focus]:ring-2">
              <span class="font-medium text-zinc-950">Choose a file</span>
              <input type="file" class="sr-only" />
            </label>
            to upload
          </span>
          <span class="max-w-80 text-center text-sm text-zinc-500">
            Upload a 3:2 image, at least 720x480 pixels, max 3MB.
          </span>
        </div>
        <div>
          <button></button>
        </div>
      </fieldset>

      <div class="col-span-full flex justify-end gap-6">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  def onboarding_step_form(%{current: :add_tickets} = assigns) do
    ~H"""
    <div class="grid grid-cols-2 gap-6 pt-4">
      <div class="col-span-full flex items-center justify-between">
        <span class="font-medium text-zinc-500">Tickets</span>
        <button class="inline-flex items-center gap-2 rounded-lg bg-zinc-50 p-2 px-3 py-2 hover:bg-zinc-100">
          <.icon name="hero-plus" class="shrink-0" />
          <span class="text-sm font-medium">Create ticket</span>
        </button>
      </div>

      <div class="col-span-full divide-y rounded-lg border">
        <div :for={_ <- 1..3} class="p-2">
          <div class="flex items-center gap-2 lg:gap-4">
            <div class="inline-flex grow items-center gap-2 truncate pl-2">
              <.icon name="hero-ticket" class="shrink-0 text-zinc-500" />
              <span class="truncate font-semibold">Early Access</span>
            </div>
            <div class="flex shrink-0 items-center gap-1 rounded-full text-zinc-500">
              <span class="text-sm font-medium">R 10 400.00</span>
            </div>

            <button class="inline-flex size-9 shrink-0 items-center justify-center rounded-lg">
              <.icon name="hero-pencil-square-mini" />
            </button>

            <button class="inline-flex size-9 shrink-0 items-center justify-center rounded-lg">
              <.icon name="hero-trash-mini" />
            </button>
          </div>
          <div class="flex gap-2 px-2">
            <div class="flex shrink-0 items-center gap-1 text-zinc-500">
              <span class="text-sm">Sale starts 12 Oct, at 09:45 AM</span>
            </div>
          </div>
        </div>
      </div>

      <div class="col-span-full flex justify-end gap-6">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  def onboarding_step_form(%{current: :payout_preferences} = assigns) do
    ~H"""
    <div class="grid gap-6 pt-4 grid-cols-[2fr_3fr]">
      <label class="col-span-full grid gap-1">
        <span class="text-sm font-medium">Account Holder</span>
        <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
      </label>

      <label class="grid gap-1">
        <span class="text-sm font-medium">Bank</span>
        <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
      </label>

      <label class="grid gap-1">
        <span class="text-sm font-medium">Account Number</span>
        <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
      </label>

      <fieldset class="col-span-full grid gap-4 lg:grid-cols-2 lg:gap-6">
        <legend class="col-span-full inline-flex text-sm font-medium">
          Payout schedule
        </legend>

        <label class="mt-1 flex gap-2 rounded-lg border px-3 py-2 has-[:checked]:ring-2 has-[:checked]:ring-zinc-600">
          <input type="radio" name="event-location" checked class="peer sr-only" />
          <div class="grid grow gap-1">
            <span class="text-sm font-medium text-zinc-950">Automatic</span>
            <span class="text-sm text-zinc-500">
              Only people with the link to the event will be able to see it
            </span>
          </div>
          <.icon
            name="hero-check-circle-mini"
            class="shrink-0 text-zinc-700 opacity-0 peer-checked:opacity-100"
          />
        </label>

        <label class="mt-1 flex gap-2 rounded-lg border px-3 py-2 has-[:disabled]:opacity-60 has-[:checked]:ring-2 has-[:checked]:ring-zinc-600">
          <input type="radio" name="event-location" disabled class="peer sr-only" />
          <div class="grid grow gap-1">
            <span class="text-sm font-medium text-zinc-950">Manual</span>
            <span class="text-sm text-zinc-500">
              The event will be publicly discoverable on the platform
            </span>
          </div>
          <.icon
            name="hero-check-circle-mini"
            class="shrink-0 text-zinc-700 opacity-0 peer-checked:opacity-100"
          />
        </label>
      </fieldset>

      <div class="col-span-full flex justify-end gap-6">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  def onboarding_step_form(%{current: :summary} = assigns) do
    ~H"""
    <div class="grid grid-cols-2 gap-8 pt-4">
      <div class="col-span-full space-y-2">
        <label class="col-span-full grid gap-1">
          <span class="text-sm font-medium">Name</span>
          <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
        </label>

        <label class="col-span-full grid gap-1">
          <div class="flex items-center rounded-lg border border-zinc-300 pl-3">
            <span class="text-sm text-zinc-500">gits.co.za/hosts/</span>
            <input
              type="text"
              class="w-full rounded-lg border-none py-2 pl-0 pr-3 text-sm focus-visible:ring-0"
            />
          </div>
        </label>
      </div>

      <div class="col-span-full grid grid-cols-[auto_1fr] items-center gap-1 gap-x-4">
        <span class="col-span-full w-full text-sm font-medium">Upload logo</span>
        <div class="aspect-square w-24 rounded-xl bg-zinc-200"></div>
        <div class="inline-grid">
          <label class="inline-flex">
            <span class="sr-only">Choose logo</span>
            <input
              type="file"
              class="w-full text-sm font-medium file:mr-4 file:h-9 file:rounded-lg file:border file:border-solid file:border-zinc-300 file:bg-white file:px-4 file:py-2 hover:file:bg-zinc-50"
            />
          </label>
        </div>
      </div>

      <div class="col-span-full flex justify-end gap-6">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
