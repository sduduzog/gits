defmodule GitsWeb.HostLive.OnboardingComponents do
  use Phoenix.Component
  use GitsWeb, :verified_routes

  import GitsWeb.CoreComponents
  # alias Phoenix.LiveView.JS

  def onboarding_step_form(%{current: :sign_up} = assigns) do
    ~H"""
    <div class="grid grid-cols-2 gap-6 pt-4">
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
              class="w-full rounded-lg border-none py-2 pr-3 pl-0 text-sm focus-visible:ring-0"
            />
          </div>
        </label>
      </div>

      <div class="grid-cols-[auto_1fr] col-span-full grid items-center gap-1 gap-x-4">
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

  def onboarding_step_form(%{current: :create_event} = assigns) do
    ~H"""
    <div class="grid grid-cols-2 gap-6 pt-4">
      <label for="" class="col-span-full grid gap-1">
        <span class="text-sm font-medium">What is the name of your event?</span>
        <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
      </label>

      <label for="" class="grid gap-1">
        <span class="text-sm font-medium">Bank Type</span>
        <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
      </label>

      <label for="" class="grid gap-1">
        <span class="text-sm font-medium">Account Number</span>
        <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
      </label>

      <fieldset class="col-span-full grid grid-cols-2 gap-4">
        <legend class="col-span-full inline-flex text-sm font-medium">
          Prefered payout schedule
        </legend>

        <label class="mt-1 flex gap-2 rounded-lg border p-4 has-[:checked]:ring-2 has-[:checked]:ring-zinc-600">
          <input type="radio" name="event-location" checked class="peer sr-only" />
          <div class="grid grow gap-2">
            <span class="text-sm font-medium text-zinc-950">Automatic</span>
            <span class="hidden text-sm text-zinc-500">
              Lorem ipsum dolor sit amet consectetur adipisicing.
            </span>
          </div>
          <.icon
            name="hero-check-circle-mini"
            class="shrink-0 opacity-0 peer-checked:opacity-100 text-zinc-700"
          />
        </label>

        <label class="mt-1 flex gap-2 rounded-lg border p-4 has-[:checked]:ring-2 has-[:checked]:ring-zinc-600 has-[:disabled]:opacity-60">
          <input type="radio" name="event-location" class="peer sr-only" />
          <div class="grid grow gap-2">
            <span class="text-sm font-medium text-zinc-950">Manual</span>
            <span class="hidden text-sm text-zinc-500">
              Lorem, ipsum dolor sit amet consectetur adipisicing elit.
            </span>
          </div>
          <.icon
            name="hero-check-circle-mini"
            class="opacity-0 shrink-0 peer-checked:opacity-100 text-zinc-700"
          />
        </label>
      </fieldset>

      <div class="col-span-full flex justify-end gap-6">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  def onboarding_step_form(%{current: :payouts} = assigns) do
    ~H"""
    <div class="grid grid-cols-2 gap-8 pt-4">
      <label for="" class="col-span-full grid gap-1">
        <span class="text-sm font-medium">Account Name</span>
        <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
      </label>

      <label for="" class="grid gap-1">
        <span class="text-sm font-medium">Bank Type</span>
        <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
      </label>

      <label for="" class="grid gap-1">
        <span class="text-sm font-medium">Account Number</span>
        <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
      </label>

      <fieldset class="col-span-full grid gap-4 lg:grid-cols-2">
        <legend class="col-span-full inline-flex text-sm font-medium">
          Prefered payout schedule
        </legend>

        <label class="mt-1 flex gap-2 rounded-lg border p-4 has-[:checked]:ring-2 has-[:checked]:ring-zinc-600">
          <input type="radio" name="event-location" checked class="peer sr-only" />
          <div class="grid grow gap-2">
            <span class="text-sm font-medium text-zinc-950">Automatic</span>
            <span class="text-sm text-zinc-500">
              Lorem ipsum dolor sit amet consectetur adipisicing.
            </span>
          </div>
          <.icon
            name="hero-check-circle-mini"
            class="shrink-0 opacity-0 peer-checked:opacity-100 text-zinc-700"
          />
        </label>

        <label class="mt-1 flex gap-2 rounded-lg border p-4 has-[:checked]:ring-2 has-[:checked]:ring-zinc-600 has-[:disabled]:opacity-60">
          <input type="radio" name="event-location" class="peer sr-only" />
          <div class="grid grow gap-2">
            <span class="text-sm font-medium text-zinc-950">Manual</span>
            <span class="text-sm text-zinc-500">
              Lorem, ipsum dolor sit amet consectetur adipisicing elit.
            </span>
          </div>
          <.icon
            name="hero-check-circle-mini"
            class="opacity-0 shrink-0 peer-checked:opacity-100 text-zinc-700"
          />
        </label>
      </fieldset>

      <div class="col-span-full flex justify-end gap-6">
        <button class="rounded-lg px-4 py-2 text-zinc-950 hover:bg-zinc-50" phx-click="skip">
          <span class="text-sm font-medium">Skip</span>
        </button>

        <button class="rounded-lg bg-zinc-900 px-4 py-2 text-zinc-50" phx-click="continue">
          <span class="text-sm font-medium">Continue</span>
        </button>
      </div>
    </div>
    """
  end

  def onboarding_step_form(%{current: :payouts} = assigns) do
    ~H"""
    <div class="grid grid-cols-2 gap-8 pt-4">
      <label for="" class="col-span-full grid gap-1">
        <span class="text-sm font-medium">Account Name</span>
        <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
      </label>

      <label for="" class="grid gap-1">
        <span class="text-sm font-medium">Bank Type</span>
        <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
      </label>

      <label for="" class="grid gap-1">
        <span class="text-sm font-medium">Account Number</span>
        <input type="text" class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm" />
      </label>

      <fieldset class="col-span-full grid gap-4 lg:grid-cols-2">
        <legend class="col-span-full inline-flex text-sm font-medium">
          Prefered payout schedule
        </legend>

        <label class="mt-1 flex gap-2 rounded-lg border p-4 has-[:checked]:ring-2 has-[:checked]:ring-zinc-600">
          <input type="radio" name="event-location" checked class="peer sr-only" />
          <div class="grid grow gap-2">
            <span class="text-sm font-medium text-zinc-950">Automatic</span>
            <span class="text-sm text-zinc-500">
              Lorem ipsum dolor sit amet consectetur adipisicing.
            </span>
          </div>
          <.icon
            name="hero-check-circle-mini"
            class="shrink-0 opacity-0 peer-checked:opacity-100 text-zinc-700"
          />
        </label>

        <label class="mt-1 flex gap-2 rounded-lg border p-4 has-[:checked]:ring-2 has-[:checked]:ring-zinc-600 has-[:disabled]:opacity-60">
          <input type="radio" name="event-location" class="peer sr-only" />
          <div class="grid grow gap-2">
            <span class="text-sm font-medium text-zinc-950">Manual</span>
            <span class="text-sm text-zinc-500">
              Lorem, ipsum dolor sit amet consectetur adipisicing elit.
            </span>
          </div>
          <.icon
            name="hero-check-circle-mini"
            class="opacity-0 shrink-0 peer-checked:opacity-100 text-zinc-700"
          />
        </label>
      </fieldset>

      <div class="col-span-full flex justify-end gap-6">
        <button class="rounded-lg px-4 py-2 text-zinc-950 hover:bg-zinc-50" phx-click="skip">
          <span class="text-sm font-medium">Skip</span>
        </button>

        <button class="rounded-lg bg-zinc-900 px-4 py-2 text-zinc-50" phx-click="continue">
          <span class="text-sm font-medium">Continue</span>
        </button>
      </div>
    </div>
    """
  end

  def onboarding_step_form(%{current: :time_and_place} = assigns) do
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
              class="w-full rounded-lg border-none py-2 pr-3 pl-0 text-sm focus-visible:ring-0"
            />
          </div>
        </label>
      </div>

      <div class="grid-cols-[auto_1fr] col-span-full grid items-center gap-1 gap-x-4">
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

  def onboarding_step_form(%{current: :add_tickets} = assigns) do
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
              class="w-full rounded-lg border-none py-2 pr-3 pl-0 text-sm focus-visible:ring-0"
            />
          </div>
        </label>
      </div>

      <div class="grid-cols-[auto_1fr] col-span-full grid items-center gap-1 gap-x-4">
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

  def onboarding_step_form(%{current: :payout_information} = assigns) do
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
              class="w-full rounded-lg border-none py-2 pr-3 pl-0 text-sm focus-visible:ring-0"
            />
          </div>
        </label>
      </div>

      <div class="grid-cols-[auto_1fr] col-span-full grid items-center gap-1 gap-x-4">
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
              class="w-full rounded-lg border-none py-2 pr-3 pl-0 text-sm focus-visible:ring-0"
            />
          </div>
        </label>
      </div>

      <div class="grid-cols-[auto_1fr] col-span-full grid items-center gap-1 gap-x-4">
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
