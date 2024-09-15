defmodule GitsWeb.AuthLive.SignIn do
  use GitsWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket, layout: {GitsWeb.Layouts, :auth}}
  end

  def render(assigns) do
    ~H"""
    <div class="grid w-full max-w-sm gap-6">
      <h1 class="text-xl font-medium">Sign in to <span class="font-black italic">GiTS</span></h1>
      <.form for={%{}} class="grid gap-6">
        <label class="grid gap-1 text-sm">
          <span>Email</span>
          <input type="text" class="rounded-lg px-4 py-3 text-sm" />
        </label>

        <label class="grid gap-1 text-sm">
          <span>Password</span>
          <input type="text" class="rounded-lg px-4 py-3 text-sm" />
        </label>
        <button class="rounded-lg bg-zinc-900 px-4 py-3 text-sm font-medium text-zinc-50">
          Sign in
        </button>
        <div class="flex items-center gap-4 text-zinc-500">
          <span class="grow border-t "></span>
          <span class="text-sm">Or continue with</span>
          <span class="grow border-t"></span>
        </div>
        <button class="flex items-center justify-center gap-3 rounded-lg border px-4 py-3">
          <svg xmlns="http://www.w3.org/2000/svg" class="size-5" viewBox="0 0 256 262">
            <path
              fill="#4285F4"
              d="M255.878 133.451c0-10.734-.871-18.567-2.756-26.69H130.55v48.448h71.947c-1.45 12.04-9.283 30.172-26.69 42.356l-.244 1.622l38.755 30.023l2.685.268c24.659-22.774 38.875-56.282 38.875-96.027"
            /><path
              fill="#34A853"
              d="M130.55 261.1c35.248 0 64.839-11.605 86.453-31.622l-41.196-31.913c-11.024 7.688-25.82 13.055-45.257 13.055c-34.523 0-63.824-22.773-74.269-54.25l-1.531.13l-40.298 31.187l-.527 1.465C35.393 231.798 79.49 261.1 130.55 261.1"
            /><path
              fill="#FBBC05"
              d="M56.281 156.37c-2.756-8.123-4.351-16.827-4.351-25.82c0-8.994 1.595-17.697 4.206-25.82l-.073-1.73L15.26 71.312l-1.335.635C5.077 89.644 0 109.517 0 130.55s5.077 40.905 13.925 58.602z"
            /><path
              fill="#EB4335"
              d="M130.55 50.479c24.514 0 41.05 10.589 50.479 19.438l36.844-35.974C195.245 12.91 165.798 0 130.55 0C79.49 0 35.393 29.301 13.925 71.947l42.211 32.783c10.59-31.477 39.891-54.251 74.414-54.251"
            />
          </svg>
          <span class="text-sm font-medium">Google</span>
        </button>
      </.form>
    </div>
    """
  end
end
