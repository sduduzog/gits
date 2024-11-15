defmodule GitsWeb.CoreComponents do
  use Phoenix.Component
  use GitsWeb, :verified_routes

  alias Phoenix.HTML.Form
  alias Phoenix.LiveView.JS
  import GitsWeb.Gettext

  def logo(assigns) do
    ~H"""
    <.link
      navigate="/"
      class="inline-flex h-5 shrink-0 items-center justify-center rounded-lg text-xl font-black italic"
    >
      <img
        src={static_path(GitsWeb.Endpoint, ~p"/images/gits_logo.png")}
        alt="GiTS"
        class="size-full object-contain"
      />
    </.link>
    """
  end

  attr :user, :map

  def header(assigns) do
    assigns =
      assigns
      |> assign(:menus, [
        [
          {"Orders", ~p"/my/orders", false},
          {"Tickets", ~p"/my/tickets", "0"},
          {"Settings", ~p"/my/settings", false}
        ],
        [{"Sign out", ~p"/sign-out", false}]
      ])

    ~H"""
    <header class="mx-auto flex max-w-screen-xl items-center gap-2 p-2 lg:gap-8">
      <div class="flex grow items-center">
        <.logo />
      </div>
      <.link
        navigate={~p"/"}
        class="inline-flex items-center gap-1.5 rounded-lg px-4 py-2 text-sm font-semibold hover:bg-zinc-100"
      >
        <.icon name="i-lucide-search" />
        <span>Search</span>
      </.link>

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
            <button
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
              class="inline-flex h-9 items-center justify-center gap-x-1.5 rounded-lg border px-4 py-2 text-sm font-semibold ring-zinc-300 hover:bg-gray-50"
              id="menu-button"
              aria-expanded="true"
              aria-haspopup="true"
            >
              <span>Account</span>
              <.icon name="i-lucide-chevron-down" />
            </button>
          </div>
          <div
            id="header-menu"
            class="absolute hidden right-0 z-20 mt-2 w-56 origin-top-right divide-y divide-zinc-100 rounded-md bg-white shadow-lg ring-1 ring-black/5 focus:outline-none"
            role="menu"
            aria-orientation="vertical"
            aria-labelledby="menu-button"
            tabindex="-1"
          >
            <div class="px-4 py-3" role="none">
              <p class="text-sm" role="none">Signed in as</p>
              <p class="truncate text-sm font-medium text-zinc-900" role="none">
                <%= @user.email %>
              </p>
            </div>
            <div :for={{items, outer_index} <- Enum.with_index(@menus)} class="py-1" role="none">
              <.link
                :for={{{name, href, badge}, index} <- Enum.with_index(items)}
                navigate={href}
                class="flex items-center justify-between px-4 py-2 text-sm text-zinc-700 active:bg-zinc-100 hover:bg-zinc-50 active:text-zinc-900 active:outline-none"
                role="menuitem"
                tabindex="-1"
                id={"menu-item-#{outer_index}-#{index}"}
              >
                <span><%= name %></span>
                <span
                  :if={badge}
                  class="inline-flex bg-white items-center gap-x-1.5 rounded-md px-2 py-1 text-xs font-medium text-gray-900 ring-1 ring-inset ring-gray-200"
                >
                  <%= badge %>
                </span>
              </.link>
            </div>
          </div>
        </div>
      <% else %>
        <div>
          <.link
            navigate={~p"/sign-in"}
            class="inline-flex rounded-lg px-4 py-2 text-sm font-semibold hover:bg-zinc-100"
          >
            Sign in
          </.link>
        </div>
      <% end %>
    </header>
    """
  end

  attr :class, :string, default: ""

  def footer(assigns) do
    assigns =
      assigns
      |> assign(:nav_tree, [
        {"i-lucide-tickets", "Events & Hosting", [{"Host with us", "/host-with-us"}]},
        {"i-lucide-headset", "Support",
         [
           {"I need help", "/support/help"},
           {"FAQ", "/support/faq"},
           {"Contact", "/contact-us"}
         ]},
        {"i-lucide-scale", "Legal",
         [{"Terms of service", "/terms"}, {"Privacy Policy", "/privacy"}]},
        {"i-lucide-at-sign", "Social",
         [
           {"Instagram", "https://instagram.com/gits_za"},
           {"X (Formerly twitter)", "https://x.com/gits_za"}
         ]}
      ])

    ~H"""
    <footer class="grid gap-10 bg-zinc-100 py-10">
      <div class="mx-auto grid w-full max-w-screen-xl gap-8 lg:grid-cols-5">
        <div :for={{icon, heading, children} <- @nav_tree} class="space-y-2 p-4">
          <div class="flex items-center gap-3">
            <.icon name={icon} class="size-4 text-zinc-500" />
            <span class="text-xs text-zinc-500"><%= heading %></span>
          </div>
          <div class="relative grid gap-4 px-2 pt-4">
            <span class="absolute bottom-0 left-2 top-2 h-full w-[1px] bg-zinc-200"></span>
            <.link
              :for={{child, href} <- children}
              navigate={href}
              class="border-zinc-transparent z-10 inline-flex border-l pl-5 text-xs font-medium leading-4 text-zinc-950 hover:border-zinc-500 hover:text-zinc-800"
            >
              <%= child %>
            </.link>
          </div>
        </div>
      </div>
      <div class="mx-auto flex w-full max-w-screen-xl">
        <div class="space-y-4 p-2">
          <div class="grow">
            <.logo />
          </div>
          <p class="max-w-96 text-xs text-zinc-500">
            We offer better security, faster check-in, and lower costs. Whether it’s concerts, conferences, festivals, or sports events, we’ve got you covered.
          </p>
        </div>
      </div>
      <div class="mx-auto w-full max-w-screen-xl p-2">
        <span class="text-xs text-zinc-500">
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
      <div id={"#{@id}-bg"} class="fixed inset-0 bg-black/10 transition-opacity" aria-hidden="true" />
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
              class="relative hidden lg:rounded-3xl bg-white p-4 lg:shadow-lg shadow-zinc-700/10 ring-1 ring-zinc-700/10 transition"
            >
              <div class="absolute right-4 top-4">
                <button
                  phx-click={JS.exec("data-cancel", to: "##{@id}")}
                  type="button"
                  class="flex-none p-2 inline-flex justify-center items-center opacity-40 hover:opacity-60"
                  aria-label={gettext("close")}
                >
                  <.icon name="i-lucide-x" />
                </button>
              </div>
              <div id={"#{@id}-content"}>
                <%= render_slot(@inner_block) %>
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
                  <.icon name="hero-x-mark-solid" class="h-5 w-5" />
                </button>
              </div>
              <div id={"#{@id}-content"}>
                <%= render_slot(@inner_block) %>
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
      role="alert"
      class={[
        "fixed top-2 right-2 z-50 mr-2 w-80 rounded-lg p-3 ring-1 sm:w-96",
        @kind == :info && "bg-emerald-50 fill-cyan-900 text-emerald-800 ring-emerald-500",
        @kind == :warn && "bg-orange-50 fill-orange-900 text-orange-500 ring-orange-500",
        @kind == :error && "bg-rose-50 fill-rose-900 text-rose-900 shadow-md ring-rose-500"
      ]}
      {@rest}
    >
      <p :if={@title} class="flex items-center gap-1.5 text-sm font-semibold leading-6">
        <.icon :if={@kind == :info} name="hero-information-circle-mini" class="h-4 w-4" />
        <.icon :if={@kind == :warn} name="hero-information-circle-mini" class="h-4 w-4" />
        <.icon :if={@kind == :error} name="hero-exclamation-circle-mini" class="h-4 w-4" />
        <%= @title %>
      </p>
      <p class="mt-2 text-sm leading-5"><%= msg %></p>
      <button type="button" class="group absolute right-1 top-1 p-2" aria-label={gettext("close")}>
        <.icon name="hero-x-mark-solid" class="h-5 w-5 opacity-40 group-hover:opacity-70" />
      </button>
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
        <%= gettext("Attempting to reconnect") %>
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error")}
        phx-connected={hide("#server-error")}
        hidden
      >
        <%= gettext("Hang in there while we get back on track") %>
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Renders a simple form.

  ## Examples

      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:email]} label="Email"/>
        <.input field={@form[:username]} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
  """
  attr :for, :any, required: true, doc: "the datastructure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <%= render_slot(@inner_block, f) %>
    </.form>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :size, :atom, default: :sm
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  def button(assigns) do
    assigns =
      assign(
        assigns,
        :size_class,
        case assigns.size do
          :md -> "py-3 px-6"
          _ -> "py-2 px-4"
        end
      )

    ~H"""
    <button
      type={@type}
      class={[
        "rounded-lg bg-zinc-900 hover:bg-zinc-800 phx-submit-loading:opacity-75 disabled:opacity-75",
        "text-sm/6 font-semibold text-white active:text-white",
        @size_class,
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
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
    <div phx-feedback-for={@name}>
      <label class="flex items-center gap-4 text-sm leading-6 text-zinc-600">
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
        <%= @label %>
      </label>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name} class={["grid max-w-3xl gap-2 text-sm", @class]}>
      <div class="flex justify-between text-zinc-600">
        <.label for={@id}><%= @label %></.label>
      </div>

      <select
        id={@id}
        name={@name}
        class="w-full rounded-md border-zinc-300 p-4 text-sm outline-none focus:border-transparent focus:outline-none focus:ring-zinc-500"
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt} value=""><%= @prompt %></option>
        <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
      </select>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name} class={["", @class]}>
      <.label for={@id}><%= @label %></.label>
      <textarea
        id={@id}
        name={@name}
        class={[
          "mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6",
          "min-h-[6rem] phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400",
          @errors == [] && "border-zinc-300 focus:border-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        {@rest}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
      <.error :for={msg <- @errors}><%= @label <> " " <> msg %></.error>
    </div>
    """
  end

  # <label class="col-span-full grid gap-1">
  #     <span class="text-sm font-medium">What is the name of your event?</span>
  #     <input
  #       type="text"
  #       name={f[:name].name}
  #       value={f[:name].value}
  #       class="w-full rounded-lg border-zinc-300 px-3 py-2 text-sm"
  #     />
  #   </label>

  def input(assigns) do
    ~H"""
    <div class={["max-w-3xl space-y-1 text-sm", @class]}>
      <div class="flex justify-between">
        <.label for={@id}><%= @label %></.label>
        <%= if @errors == [] do %>
          <span :if={@hint} class="text-zinc-500"><%= @hint %></span>
        <% else %>
          <.error :for={msg <- @errors}><%= @label <> " " <> msg %></.error>
        <% end %>
      </div>
      <input
        class={[
          "w-full py-2 px-3 rounded-lg border border-zinc-200 focus-visible:border-transparent focus-visible:ring-2 focus-visible:ring-zinc-600 focus:outline-none outline-none",
          @errors == [] && "border-zinc-300 focus:ring-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        {@rest}
      />
      <span :if={@description} class="inline-flex text-zinc-500"><%= @description %></span>
    </div>
    """
  end

  # All other inputs text, datetime-local, url, password, etc. are handled here...
  def inputs(assigns) do
    ~H"""
    <div class={["max-w-3xl space-y-2 text-sm", @class]}>
      <div class="flex justify-between text-zinc-600">
        <.label for={@id}><%= @label %></.label>
      </div>
      <input
        class={[
          "w-full rounded-md p-4 text-sm outline-none focus:border-transparent focus:outline-none ",
          @errors == [] && "border-zinc-300 focus:ring-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        {@rest}
      />
      <.error :for={msg <- @errors}><%= @label <> " " <> msg %></.error>
    </div>

    <div :if={false} phx-feedback-for={@name}>
      <.label for={@id}><%= @label %></.label>
      <input
        type={@type}
        name={@name}
        id={@id}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={[
          "mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6",
          "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400",
          @errors == [] && "border-zinc-300 focus:border-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        {@rest}
      />
      <.error :for={msg <- @errors}><%= @label <> " " <> msg %></.error>
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
    <label for={@for} class={["block text-sm/6 font-medium text-zinc-700", @class]}>
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  attr :field, Phoenix.HTML.FormField, required: true
  attr :label, :string, required: false, default: nil
  attr :class, :string, default: ""

  slot :radio, required: true do
    attr :value, :atom, required: true
    attr :checked, :boolean
  end

  def radio_group(assigns) do
    ~H"""
    <fieldset class={["", @class]}>
      <legend class="text-sm font-medium leading-6 text-zinc-600"><%= @label %></legend>
      <!-- <p class="mt-1 text-sm leading-6 text-zinc-600">How do you prefer to receive notifications?</p> -->
      <div class="mt-6 space-y-6 sm:flex sm:items-center sm:space-x-10 sm:space-y-0">
        <div :for={{%{value: value} = rad, idx} <- Enum.with_index(@radio)} class="flex items-center">
          <input
            name={@field.name}
            id={"#{@field.id}-#{idx}"}
            value={value}
            checked={value == @field.value}
            type="radio"
            class="h-4 w-4 border-zinc-300 text-zinc-600 focus:ring-zinc-600"
          />
          <label
            for={"#{@field.id}-#{idx}"}
            class="ml-3 block text-sm font-medium leading-6 text-zinc-900"
          >
            <%= render_slot(rad) %>
          </label>
        </div>
      </div>
    </fieldset>
    """
  end

  @doc """
  Generates a generic error message.
  """
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class="flex gap-3 text-sm leading-6 text-rose-600 phx-no-feedback:hidden">
      <.icon name="hero-exclamation-circle-mini" class="mt-0.5 h-5 w-5 flex-none" />
      <%= render_slot(@inner_block) %>
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
            <%= col[:label] %>
          </th>
          <th :if={@action != []} class="relative p-0 pb-4">
            <span class="sr-only"><%= gettext("Actions") %></span>
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
                <%= render_slot(col, @row_item.(row)) %>
              </span>
            </div>
          </td>
          <td :if={@action != []} class="relative w-14 p-0">
            <div class="relative flex gap-4 whitespace-nowrap py-4 pr-2 text-right text-sm font-medium">
              <span
                :for={action <- @action}
                class="relative font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
              >
                <%= render_slot(action, @row_item.(row)) %>
              </span>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
    """
  end

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title"><%= @post.title %></:item>
        <:item title="Views"><%= @post.views %></:item>
      </.list>
  """
  slot :item, required: true do
    attr :title, :string, required: true
  end

  def list(assigns) do
    ~H"""
    <div class="mt-14">
      <dl class="-my-4 divide-y divide-zinc-100">
        <div :for={item <- @item} class="flex gap-4 py-4 text-sm leading-6 sm:gap-8">
          <dt class="w-1/4 flex-none text-zinc-500"><%= item.title %></dt>
          <dd class="text-zinc-700"><%= render_slot(item) %></dd>
        </div>
      </dl>
    </div>
    """
  end

  @doc """
  Renders a back navigation link.

  ## Examples

      <.back navigate={~p"/posts"}>Back to posts</.back>
  """
  attr :navigate, :any, required: true
  slot :inner_block, required: true

  def back(assigns) do
    ~H"""
    <div class="mt-16">
      <.link
        navigate={@navigate}
        class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
      >
        <.icon name="hero-arrow-left-solid" class="h-3 w-3" />
        <%= render_slot(@inner_block) %>
      </.link>
    </div>
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
  attr :name, :string, required: true
  attr :class, :string, default: nil

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  def icon(assigns) do
    ~H"""
    <span class={[@name, @class]}></span>
    """
  end

  ## JS Commands

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
