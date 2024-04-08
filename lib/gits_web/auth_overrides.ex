defmodule GitsWeb.AuthOverrides do
  use AshAuthentication.Phoenix.Overrides
  alias AshAuthentication.Phoenix.Components

  override Components.Banner do
    set :image_url, nil
    set :text, "GiTS"
    set :root_class, "w-full flex"
    set :text_class, "font-black italic text-3xl"
  end

  override Components.Password do
    set :toggler_class, "text-zinc-900"
  end

  override Components.Password.Input do
    set :submit_class,
        "rounded-lg bg-zinc-900 px-3 py-2 hover:bg-zinc-700 phx-submit-loading:opacity-75 text-sm font-semibold leading-6 text-white active:text-white/80"
  end
end
