defmodule GitsWeb.CoreComponents do
  use Phoenix.Component
  alias Gits.Accounts.User
  use GitsWeb, :verified_routes

  alias Phoenix.HTML.Form
  alias Phoenix.LiveView.JS
  import GitsWeb.Gettext

  def logo(assigns) do
    ~H"""
    <.link
      navigate="/"
      class="inline-block h-5 max-w-16 shrink-0 items-center justify-center rounded-lg text-xl font-black italic"
    >
      <img
        phx-track-static
        src={static_url(GitsWeb.Endpoint, "/images/gits_logo.png")}
        alt="GiTS"
        class="size-full object-contain dark:invert"
      />
    </.link>
    """
  end

  attr :user, :map

  def header(assigns) do
    tickets =
      case assigns.user do
        %User{} = user ->
          user = Ash.load!(user, [:tickets_count], actor: user)
          user.tickets_count

        _ ->
          false
      end

    assigns =
      assigns
      |> assign(:menus, [
        [
          {"Orders", ~p"/my/orders", false},
          {"Tickets", ~p"/my/tickets", tickets},
          {"Settings", ~p"/settings", false}
        ],
        [{"Sign out", ~p"/sign-out", false}]
      ])

    ~H"""
    <header class="mx-auto flex max-w-screen-xl items-center justify-start gap-2 p-2 lg:gap-8">
      <div class="items-center">
        <.logo />
      </div>
      <div class="flex grow items-center bg-red-200"></div>

      <.button :if={false} variant={:ghost} href={~p"/search"}>
        <.icon class="icon-[lucide--search]" />
        <span>Search</span>
      </.button>

      <%= if not is_nil(assigns[:user]) do %>
        <div
          class="relative inline-block text-left"
          phx-click-away={
            JS.hide(
              to: "div#header-menu[role=menu]",
              transition:
                {"transition ease-in duration-75", "transform opacity-100 scale-100",
                 "transform opacity-0 scale-95"}
            )
          }
        >
          <div>
            <.button
              phx-click={
                JS.toggle(
                  to: "div#header-menu[role=menu]",
                  in:
                    {"transition ease-out duration-100", "transform opacity-0 scale-95",
                     "transform opacity-100 scale-100"},
                  out:
                    {"transition ease-in duration-75", "transform opacity-100 scale-100",
                     "transform opacity-0 scale-95"}
                )
              }
              id="menu-button"
              variant={:outline}
              aria-expanded="true"
              aria-haspopup="true"
            >
              <span>Account</span>
              <.icon class="icon-[lucide--chevron-down]" />
            </.button>
          </div>
          <div
            id="header-menu"
            class="absolute right-0 z-20 mt-2 hidden w-56 origin-top-right divide-y divide-zinc-100 rounded-md bg-white shadow-lg ring-1 ring-black/5 focus:outline-none"
            role="menu"
            aria-orientation="vertical"
            aria-labelledby="menu-button"
            tabindex="-1"
          >
            <div class="px-4 py-3" role="none">
              <p class="text-sm" role="none">Signed in as</p>
              <p class="truncate text-sm font-medium text-zinc-900" role="none">
                {@user.email}
              </p>
            </div>
            <div :for={{items, outer_index} <- Enum.with_index(@menus)} class="py-1" role="none">
              <.link
                :for={{{name, href, badge}, index} <- Enum.with_index(items)}
                navigate={href}
                class="flex items-center justify-between px-4 py-2 text-sm text-zinc-700 hover:bg-zinc-50 active:bg-zinc-100 active:text-zinc-900 active:outline-none"
                role="menuitem"
                tabindex="-1"
                id={"menu-item-#{outer_index}-#{index}"}
              >
                <span>{name}</span>
                <span
                  :if={badge}
                  class="inline-flex items-center gap-x-1.5 rounded-md bg-white px-2 py-1 text-xs font-medium text-gray-900 ring-1 ring-inset ring-gray-200"
                >
                  {badge}
                </span>
              </.link>
            </div>
          </div>
        </div>
      <% else %>
        <div>
          <.button variant={:outline} href={~p"/sign-in"}>
            Sign in
          </.button>
        </div>
      <% end %>
    </header>
    """
  end

  attr :class, :string, default: ""
  attr :minimal, :boolean, default: false

  def footer(assigns) do
    assigns =
      assigns
      |> assign(:nav_tree, [
        {"lucide--tickets", "Events & Hosting",
         [{"Host with us", "/host-with-us"}, {"Pricing", "/pricing"}]},
        # {"lucide--headset", "Support",
        #  [
        #    # {"I need help", "/support/help"},
        #    {"FAQ", "/support/faq"},
        #    {"Contact", "/contact-us"}
        #  ]},
        {"lucide--scale", "Legal",
         [
           {"Privacy Policy", "/privacy"},
           {"Terms & Conditions", "/terms"},
           {"Refund Policy", "/refund-policy"}
         ]},
        {"lucide--at-sign", "Social",
         [
           {"Instagram", "https://instagram.com/gits_za"},
           {"X (Formerly twitter)", "https://x.com/gits_za"}
         ]}
      ])

    ~H"""
    <footer class="grid gap-10 bg-zinc-50 py-10 dark:bg-zinc-900">
      <div :if={not @minimal} class="mx-auto grid w-full max-w-screen-xl gap-8 lg:grid-cols-5">
        <div :for={{icon, heading, children} <- @nav_tree} class="space-y-2 p-4">
          <div class="flex items-center gap-3">
            <.icon name={icon} class="size-4 text-zinc-400" />
            <span class="text-xs text-zinc-500 dark:text-zinc-300">{heading}</span>
          </div>
          <div class="relative grid gap-4 px-2 pt-4">
            <span class="absolute bottom-0 left-2 top-2 h-full w-[1px] bg-zinc-200 dark:bg-zinc-700">
            </span>
            <.link
              :for={{child, href} <- children}
              navigate={href}
              class="z-10 inline-flex border-l border-transparent pl-5 text-xs font-medium leading-4 text-zinc-950 hover:border-zinc-500 dark:border-zinc-700 dark:text-zinc-100 dark:hover:border-zinc-100"
            >
              {child}
            </.link>
          </div>
        </div>
      </div>
      <div class="mx-auto flex w-full max-w-screen-xl">
        <div class="space-y-4 p-2">
          <div class="grow">
            <.logo />
          </div>
          <p class="max-w-96 text-xs text-zinc-500 dark:text-zinc-300">
            We offer better security, faster check-in, and lower costs. Whether it’s concerts, conferences, festivals, or sports events, we’ve got you covered.
          </p>
        </div>
      </div>
      <div class="mx-auto w-full max-w-screen-xl p-2">
        <span class="text-xs text-zinc-500 dark:text-zinc-300">
          &copy; 2024 PRPL Group | All Rights Reserved
        </span>
      </div>
    </footer>
    """
  end

  @doc """
  Renders a modal.

  ## Examples

      <.modal id="confirm-modal">
        This is a modal.
      </.modal>

  JS commands may be passed to the `:on_cancel` to configure
  the closing/cancel event, for example:

      <.modal id="confirm" on_cancel={JS.navigate(~p"/posts")}>
        This is another modal.
      </.modal>

  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  attr :new, :boolean, default: false
  attr :size, :atom, default: :sm
  slot :inner_block, required: true

  def modal(%{new: true} = assigns) do
    assigns =
      assign(
        assigns,
        :size_class,
        case assigns.size do
          :sm -> "max-w-lg"
          :lg -> "max-w-5xl"
        end
      )

    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      class="relative z-50 hidden"
    >
      <div
        id={"#{@id}-bg"}
        class="bg-black/20x fixed inset-0 bg-zinc-50/50 transition-opacity"
        aria-hidden="true"
      />
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex min-h-full items-end justify-center sm:items-center">
          <div class={["w-full sm:p-6 lg:py-8", @size_class]}>
            <.focus_wrap
              id={"#{@id}-container"}
              phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
              phx-key="escape"
              phx-click-away={JS.exec("data-cancel", to: "##{@id}")}
              class="relative hidden bg-white p-4 shadow-zinc-700/10 ring-1 ring-zinc-700/10 transition lg:rounded-2xl lg:shadow-lg"
            >
              <div class="absolute right-4 top-4">
                <button
                  phx-click={JS.exec("data-cancel", to: "##{@id}")}
                  type="button"
                  class="inline-flex flex-none items-center justify-center p-2 opacity-40 hover:opacity-60"
                  aria-label={gettext("close")}
                >
                  <.icon name="lucide--x" />
                </button>
              </div>
              <div id={"#{@id}-content"} class="p-2">
                {render_slot(@inner_block)}
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      class="relative z-50 hidden"
    >
      <div id={"#{@id}-bg"} class="fixed inset-0 bg-zinc-50/90 transition-opacity" aria-hidden="true" />
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex min-h-full items-end justify-center sm:items-center">
          <div class="w-full max-w-3xl p-4 sm:p-6 lg:py-8">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-window-keydown={JS.exec("data-cancel", to: "##{@id}")}
              phx-key="escape"
              phx-click-away={JS.exec("data-cancel", to: "##{@id}")}
              class="relative hidden rounded-2xl bg-white px-8 py-6 shadow-lg shadow-zinc-700/10 ring-1 ring-zinc-700/10 transition sm:p-14"
            >
              <div class="absolute right-5 top-6">
                <button
                  phx-click={JS.exec("data-cancel", to: "##{@id}")}
                  type="button"
                  class="-m-3 flex-none p-3 opacity-20 hover:opacity-40"
                  aria-label={gettext("close")}
                >
                  <.icon class="h-5 w-5 ri--close-line" />
                </button>
              </div>
              <div id={"#{@id}-content"}>
                {render_slot(@inner_block)}
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :warn, :error], doc: "used for styling and flash lookup"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      phx-hook="AutoClearFlash"
      class={[
        "fixed top-2 right-4 z-50 w-full max-w-96",
        "bg-white rounded-lg border border-border bg-background p-4 shadow-lg shadow-black/5"
      ]}
      role="alert"
      {@rest}
    >
      <div class="flex gap-2">
        <div class="flex grow gap-3">
          <.icon :if={@kind == :info} class="mt-0.5 text-emerald-500 ri--information-line" />
          <.icon :if={@kind == :warn} class="mt-0.5 text-orange-500 ri--information-line" />
          <.icon :if={@kind == :error} class="mt-0.5 text-rose-500 ri--error-warning-line" />

          <div class="flex grow flex-col gap-3">
            <div class="space-y-1">
              <p class="text-sm font-medium">{@title}</p>
              <p class="inline-flex flex-wrap text-sm text-zinc-500">
                {msg}
              </p>
            </div>
          </div>
          <button
            aria-label={gettext("close")}
            class="focus-visible:outline-ring/70 [&amp;_svg]:pointer-events-none [&amp;_svg]:shrink-0 hover:text-accent-foreground group -my-1.5 -me-2 inline-flex size-8 shrink-0 items-center justify-center whitespace-nowrap rounded-lg p-0 text-sm font-medium outline-offset-2 transition-colors hover:bg-transparent focus-visible:outline focus-visible:outline-2 disabled:pointer-events-none disabled:opacity-50"
          >
            <.icon class="h-5 w-5 opacity-60 ri--close-line group-hover:opacity-70" />
          </button>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id}>
      <.flash kind={:info} title={gettext("Success!")} flash={@flash} />
      <.flash kind={:warn} title={gettext("Warning!")} flash={@flash} />
      <.flash kind={:error} title={gettext("Error!")} flash={@flash} />
      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error")}
        phx-connected={hide("#client-error")}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon class="ml-1 mt-0.5 animate-spin ri--loader-4-line" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error")}
        phx-connected={hide("#server-error")}
        hidden
      >
        {gettext("Hang in there while we get back on track")}
        <.icon class="ml-1 mt-0.5 animate-spin ri--loader-4-line" />
      </.flash>
    </div>
    """
  end

  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :size, :atom, default: nil
  attr :variant, :atom, default: nil
  attr :rest, :global, include: ~w(disabled form name value href navigate patch)

  slot :inner_block, required: true

  def button(assigns) do
    link? =
      assigns
      |> Map.get(:rest)
      |> Map.keys()
      |> Enum.any?(&Enum.member?([:href, :navigate, :patch], &1))

    size_classes =
      case assigns.size do
        :lg -> "py-4 px-8 text-base/6"
        :md -> "py-3 px-6 text-sm/4"
        :sm -> "py-2 px-4 text-sm/4"
        :box -> "p-2 text-sm/4"
        :none -> "text-sm/4"
        _ -> "py-3 px-4 text-sm/4"
      end

    variant_classes =
      case assigns.variant do
        :accent ->
          "border-transparent text-white active:text-white bg-brand-500 hover:bg-brand-600 active:bg-brand-700  phx-submit-loading:bg-brand-100 phx-submit-loading:text-brand-400 disabled:bg-brand-100 disabled:text-brand-400"

        :surface ->
          "border-zinc-200 bg-zinc-50 text-zinc-950 hover:bg-zinc-100"

        :outline ->
          "text-zinc-400 border-zinc-200 hover:text-zinc-500 hover:border-zinc-500 active:text-zinc-600 active:border-zinc-600 disabled:text-zinc-100 disabled:border-zinc-100 dark:disabled:text-zinc-800 dark:disabled:border-zinc-800"

        :danger ->
          "text-rose-400 border-rose-200 hover:text-rose-500 hover:border-rose-500 active:text-rose-600 active:border-rose-600 disabled:text-rose-100 disabled:border-rose-100 dark:disabled:text-rose-800 dark:disabled:border-rose-800"

        :ghost ->
          "border-transparent bg-transparent text-zinc-400 hover:text-zinc-500"

        :solid ->
          "border-transparent bg-zinc-500 text-white active:text-white bg-black hover:bg-zinc-600 active:bg-zinc-700  phx-submit-loading:bg-zinc-100 phx-submit-loading:text-zinc-400 disabled:bg-zinc-100 disabled:text-zinc-400 dark:phx-loading:text-zinc-700 dark:phx-loading:bg-zinc-950 dark:disabled:text-zinc-700 dark:disabled:bg-zinc-950"

        _ ->
          "border-transparent bg-zinc-50 text-zinc-500 hover:bg-zinc-100 disabled:bg-zinc-50 hover:dark:text-zinc-400 dark:bg-zinc-950 hover:dark:bg-zinc-900 active:dark:text-zinc-300 active:dark:bg-zinc-800 disabled:text-zinc-200 disabled:bg-transparent"
      end

    assigns =
      assigns
      |> assign(:link?, link?)
      |> assign(
        :base_class,
        [
          size_classes,
          variant_classes,
          "font-medium  border inline-flex gap-2",
          "rounded-lg items-center justify-center",
          "outline-none focus:outline-none focus-visible:ring-2 focus-visible:ring-zinc-200 dark:focus-visible:ring-zinc-700"
        ]
      )

    ~H"""
    <%= if @link? do %>
      <.link type={@type} class={[@base_class, @class]} {@rest}>
        {render_slot(@inner_block)}
      </.link>
    <% else %>
      <button type={@type} class={[@base_class, @class]} {@rest}>
        {render_slot(@inner_block)}
      </button>
    <% end %>
    """
  end

  @doc """
  Renders an input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  This function accepts all HTML input types, considering that:

    * You may also set `type="select"` to render a `<select>` tag

    * `type="checkbox"` is used exclusively to render boolean values

    * For live file uploads, see `Phoenix.Component.live_file_input/1`

  See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
  for more information.

  ## Examples

      <.input field={@form[:email]} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :hint, :string, default: nil
  attr :description, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number password
               range radio search select tel text textarea time url week)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :class, :string, default: ""

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  slot :inner_block

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div class={["max-w-3xl space-y-1 text-sm", @class]}>
      <div phx-feedback-for={@name} class="flex items-center gap-2">
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          class="rounded border-zinc-300 text-zinc-900 focus:ring-0"
          {@rest}
        />

        <.label for={@id}>{@label}</.label>
        <%= if @errors == [] do %>
          <span :if={@hint} class="text-zinc-500">&nbsp;({@hint})</span>
        <% else %>
          <.error :for={msg <- @errors}>{msg}</.error>
        <% end %>
      </div>
      <span :if={@description} class="inline-flex text-zinc-500">{@description}</span>
    </div>
    """
  end

  def input(%{type: "radio"} = assigns) do
    ~H"""
    <fieldset class={@class}>
      <legend class="text-sm/6 font-semibold text-gray-900">{@label}</legend>
      <%= if @errors == [] do %>
        <p :if={@hint} class="mt-1 text-sm/6 text-gray-600">{@hint}</p>
      <% else %>
        <.error :for={msg <- @errors}>{msg}</.error>
      <% end %>

      <div class="mt-4 space-y-4 sm:flex sm:items-center sm:space-x-10 sm:space-y-0">
        <div :for={{item, index} <- Enum.with_index(@options, 1)} class="flex items-center">
          <input
            id={item}
            name={@name}
            checked={(is_nil(@value) and index == 1) or @value == item}
            type="radio"
            value={item}
            class="relative size-4 appearance-none rounded-full border border-gray-300 bg-white text-zinc-950 before:absolute before:inset-1 before:rounded-full before:bg-white checked:border-zinc-600 checked:bg-zinc-600 focus:ring-zinc-950 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-zinc-600 disabled:border-gray-300 disabled:bg-gray-100 disabled:before:bg-gray-400 forced-colors:appearance-auto forced-colors:before:hidden [&:not(:checked)]:before:hidden"
          />
          <label for={item} class="ml-3 block text-sm/6 font-medium capitalize text-gray-900">
            {item}
          </label>
        </div>
      </div>
    </fieldset>

    <fieldset :if={false} class={["max-w-3xl space-y-1 text-sm", @class]}>
      <legend class="inline-flex w-full items-center justify-between text-sm font-medium">
        <span class="block text-sm/6 font-medium text-zinc-700">{@label}</span>
        <%= if @errors == [] do %>
          <span :if={@hint} class="text-zinc-500">{@hint}</span>
        <% else %>
          <.error :for={msg <- @errors}>{msg}</.error>
        <% end %>
      </legend>

      <div class="flex flex-wrap gap-4">
        <label
          :for={{item, index} <- Enum.with_index(@options, 1)}
          for={item}
          class={[
            "inline-flex py-2 text-sm px-3 rounded-lg border",
            "border-zinc-200 focus-visible:border-transparent focus-visible:ring-2 focus-visible:outline-none outline-none",
            "has-[:checked]:ring-2 has-[:checked]:ring-zinc-600",
            @errors == [] && "border-zinc-300 focus-visible:ring-zinc-600",
            @errors != [] && "border-rose-400 focus-visible:border-rose-600"
          ]}
        >
          <input
            type="radio"
            id={item}
            name={@name}
            value={item}
            class="peer sr-only"
            checked={@value == item or (index == 1 and is_nil(@value))}
          />
          <span class="">
            {to_string(item)
            |> String.split("_")
            |> Enum.map(&String.capitalize(&1))
            |> Enum.join(" ")}
          </span>
        </label>
      </div>
    </fieldset>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div class={["max-w-3xl space-y-1 text-sm", @class]}>
      <div phx-feedback-for={@name} class="flex justify-between">
        <.label for={@id}>{@label}</.label>
        <%= if @errors == [] do %>
          <span :if={@hint} class="text-zinc-500">{@hint}</span>
        <% else %>
          <.error :for={msg <- @errors}>{msg}</.error>
        <% end %>
      </div>
      <select
        id={@id}
        name={@name}
        class={[
          "w-full p-3 text-sm rounded-lg",
          "bg-transparent border border-zinc-400",
          "text-zinc-900 dark:text-zinc-200",
          "focus-visible:outline-none focus-visible:border-zinc-400 focus-visible:ring-2 focus-visible:ring-zinc-200 focus-visible:dark:ring-zinc-700",
          @errors == [] && "border-zinc-300 focus:ring-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt} value="">{@prompt}</option>
        {Phoenix.HTML.Form.options_for_select(@options, @value)}
      </select>
      <span :if={@description} class="inline-flex text-zinc-500">{@description}</span>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name} class={["max-w-3xl space-y-1 text-sm", @class]}>
      <div class="flex justify-between">
        <.label for={@id}>{@label}</.label>
        <%= if @errors == [] do %>
          <span :if={@hint} class="text-zinc-500">{@hint}</span>
        <% else %>
          <.error :for={msg <- @errors}>{msg}</.error>
        <% end %>
      </div>
      <textarea
        class={[
          "w-full text-sm p-3 rounded-lg",
          "bg-transparent border border-zinc-400",
          "text-zinc-900 dark:text-zinc-200",
          "focus-visible:outline-none focus-visible:border-zinc-400 focus-visible:ring-2 focus-visible:ring-zinc-200 focus-visible:dark:ring-zinc-700",
          @errors == [] && "border-zinc-300 focus:ring-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        id={@id}
        name={@name}
        {@rest}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
      <span :if={@description} class="inline-flex text-zinc-500">{@description}</span>
    </div>
    """
  end

  def input(%{type: "richtext"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name} class={["max-w-3xl space-y-1 text-sm", @class]}>
      <div class="flex justify-between">
        <.label for={@id}>{@label}</.label>
        <%= if @errors == [] do %>
          <span :if={@hint} class="text-zinc-500">{@hint}</span>
        <% else %>
          <.error :for={msg <- @errors}>{msg}</.error>
        <% end %>
      </div>
      <div
        id={@id}
        name={@name}
        phx-update="ignore"
        data-contents={@value}
        phx-hook="QuillEditor"
        class="quill-editor h-full"
      >
      </div>
      <span :if={@description} class="inline-flex text-zinc-500">{@description}</span>
    </div>
    """
  end

  def input(%{type: "hidden"} = assigns) do
    ~H"""
    <input
      type={@type}
      name={@name}
      id={@id}
      value={Phoenix.HTML.Form.normalize_value(@type, @value)}
      {@rest}
    />
    """
  end

  def input(%{type: "color"} = assigns) do
    ~H"""
    <div class={["max-w-3xl space-y-1 text-sm", @class]}>
      <div phx-feedback-for={@name} class="flex justify-between">
        <.label for={@id}>{@label}</.label>
        <%= if @errors == [] do %>
          <span :if={@hint} class="text-zinc-500">{@hint}</span>
        <% else %>
          <.error :for={msg <- @errors}>{msg}</.error>
        <% end %>
      </div>
      <div class={
        [
          "relative",
          "p-3 flex gap-2",
          "w-full text-sm rounded-lg",
          # "relative inline-flex w-full items-center gap-2 rounded-lg border border-zinc-200 text-sm outline-none focus:outline-none focus-visible:border-transparent focus-visible:ring-2 focus-visible:ring-zinc-600"
          "bg-transparent border border-zinc-400",
          "text-zinc-900 dark:text-zinc-200",
          "has-[:focus-visible]:outline-none",
          "focus-visible:outline-none focus-visible:border-zinc-400 focus-visible:ring-2 focus-visible:ring-zinc-200 focus-visible:dark:ring-zinc-700",
          @errors == [] && "border-zinc-300 focus:ring-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]
      }>
        <input type="color" name={@name} value={@value} class="absolute inset-0 size-full opacity-0" />
        <span class="inline-flex size-5 rounded-full" style={"background-color: #{@value}"}></span>
        <span>{@value}</span>
      </div>
      <span :if={@description} class="inline-flex text-zinc-500">{@description}</span>
    </div>
    """
  end

  def input(assigns) do
    ~H"""
    <div class={["max-w-3xl space-y-1 text-sm", @class]}>
      <div phx-feedback-for={@name} class="flex justify-between">
        <.label for={@id}>{@label}</.label>
        <%= if @errors == [] do %>
          <span :if={@hint} class="text-zinc-500">{@hint}</span>
        <% else %>
          <.error :for={msg <- @errors}>{msg}</.error>
        <% end %>
      </div>
      <input
        class={[
          "p-3",
          "w-full text-sm rounded-lg",
          "bg-transparent border border-zinc-400",
          "text-zinc-900 dark:text-zinc-200",
          "focus-visible:outline-none focus-visible:border-zinc-400 focus-visible:ring-2 focus-visible:ring-zinc-200 focus-visible:dark:ring-zinc-700",
          @errors == [] && "border-zinc-300 focus:ring-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        {@rest}
      />
      <span :if={@description} class="inline-flex text-zinc-500">{@description}</span>
    </div>
    """
  end

  @doc """
  Renders a label.
  """
  attr :for, :string, default: nil
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label for={@for} class={["block text-sm/6 font-medium text-zinc-700 dark:text-zinc-300", @class]}>
      {render_slot(@inner_block)}
    </label>
    """
  end

  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class="flex gap-2 text-sm leading-6 text-rose-600 phx-no-feedback:hidden">
      <.icon class="mt-0.5 text-lg ri--error-warning-line flex-none" />
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id"><%= user.id %></:col>
        <:col :let={user} label="username"><%= user.username %></:col>
      </.table>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: true do
    attr :label, :string
    attr :optional, :boolean
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <table class="w-full">
      <thead class="text-left text-sm leading-6 text-zinc-500">
        <tr>
          <th
            :for={col <- @col}
            class={[
              "py-4 truncate px-2 font-normal",
              if(col[:optional], do: "hidden lg:table-cell", else: "")
            ]}
          >
            {col[:label]}
          </th>
          <th :if={@action != []} class="relative p-0 pb-4">
            <span class="sr-only">{gettext("Actions")}</span>
          </th>
        </tr>
      </thead>
      <tbody
        id={@id}
        phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}
        class="relative divide-y divide-zinc-100 border-t border-zinc-100 text-sm leading-6 text-zinc-700"
      >
        <tr :for={row <- @rows} id={@row_id && @row_id.(row)} class="group hover:bg-zinc-50">
          <td
            :for={{col, i} <- Enum.with_index(@col)}
            phx-click={@row_click && @row_click.(row)}
            class={[
              "relative p-0",
              @row_click && "hover:cursor-pointer",
              if(col[:optional], do: "hidden lg:table-cell", else: "")
            ]}
          >
            <div class="w-full px-2 py-4 hover:bg-zinc-50">
              <span class={["relative", i == 0 && "font-semibold text-zinc-900"]}>
                {render_slot(col, @row_item.(row))}
              </span>
            </div>
          </td>
          <td :if={@action != []} class="relative w-14 p-0">
            <div class="relative flex gap-4 whitespace-nowrap py-4 pr-2 text-right text-sm font-medium">
              <span
                :for={action <- @action}
                class="relative font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
              >
                {render_slot(action, @row_item.(row))}
              </span>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
    """
  end

  @doc """
  Renders a [Heroicon](https://heroicons.com).

  Heroicons come in three styles – outline, solid, and mini.
  By default, the outline style is used, but solid and mini may
  be applied by using the `-solid` and `-mini` suffix.

  You can customize the size and colors of the icons by setting
  width, height, and background color classes.

  Icons are extracted from the `deps/heroicons` directory and bundled within
  your compiled app.css by the plugin in your `assets/tailwind.config.js`.

  ## Examples

      <.icon name="hero-x-mark-solid" />
      <.icon name="hero-arrow-path" class="ml-1 w-3 h-3 animate-spin" />
  """
  attr :class, :string, default: nil

  def icon(assigns) do
    ~H"""
    <span class={["", @class]}></span>
    """
  end

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(GitsWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(GitsWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end
