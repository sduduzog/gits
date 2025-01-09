defmodule GitsWeb.HostLive.Settings do
  alias AshPhoenix.Form
  alias Gits.PaystackApi
  use GitsWeb, :host_live_view

  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Settings")
    |> assign(:section, nil)
    |> ok()
  end

  def handle_params(_, _, socket) do
    %{host: host, current_user: user} = socket.assigns

    case socket.assigns.live_action do
      :general ->
        assign(socket, :section, "General")
        |> assign(:uploaded_files, [])
        |> allow_upload(:logo, accept: ~w(.jpg .jpeg .png .webp), max_entries: 1)
        |> assign(:form, Form.for_update(host, :update, actor: user))

      :billing ->
        host =
          Ash.load!(
            host,
            [
              :paystack_subaccount,
              :paystack_business_name,
              :paystack_account_number,
              :paystack_settlement_bank
            ],
            actor: user
          )

        assign(socket, :section, "Billing & Payouts")
        |> assign(
          :banks,
          PaystackApi.list_banks!(:cache)
          |> Enum.map(&{&1.name, &1.code})
        )
        |> assign(:form, Form.for_update(host, :paystack_subaccount, actor: user))

      :index ->
        host =
          Ash.load!(
            host,
            [
              :paystack_subaccount,
              :paystack_business_name,
              :paystack_account_number,
              :paystack_settlement_bank
            ],
            actor: user
          )

        bank_name =
          PaystackApi.list_banks!(:cache)
          |> Enum.find(&(&1.code == host.paystack_settlement_bank))
          |> case do
            %{name: name} -> name
            _ -> nil
          end

        assign(socket, :page_title, "Settings")
        |> assign(:host, host)
        |> assign(:bank_name, bank_name)
    end
    |> noreply()
  end

  def handle_event("upload", unsigned_params, socket) do
    %{form: form} = socket.assigns

    filename =
      consume_uploaded_entries(socket, :logo, fn %{path: path}, _entry ->
        bucket_name = Application.get_env(:gits, :bucket_name)

        filename = Nanoid.generate(24) <> ".jpg"

        Image.open!(path)
        |> Image.thumbnail!("256x256", fit: :cover)
        |> Image.stream!(suffix: ".jpg", buffer_size: 5_242_880, quality: 100)
        |> ExAws.S3.upload(
          bucket_name,
          filename,
          content_type: "image/jpeg",
          cache_control: "public,max-age=3600"
        )
        |> ExAws.request()

        {:ok, filename}
      end)
      |> case do
        [filename] ->
          filename

        [] ->
          nil
      end

    Ash.Changeset.for_update(socket.assigns.host, :update, %{logo: filename})
    |> Ash.update(actor: socket.assigns.current_user)
    |> case do
      {:ok, host} ->
        socket
        |> assign(:host, host)
        |> noreply()
    end
  end

  def handle_event("validate", unsigned_params, socket) do
    form =
      socket.assigns.form
      |> Form.validate(unsigned_params["form"])

    socket
    |> assign(:form, form)
    |> noreply()
  end

  def handle_event("submit", unsigned_params, socket) do
    %{form: form, current_user: user} = socket.assigns

    case socket.assigns.live_action do
      :general ->
        Form.submit(form, params: unsigned_params["form"])
        |> case do
          {:ok, host} ->
            assign(socket, :form, Form.for_update(host, :update, actor: user))

          {:error, form} ->
            assign(socket, :form, form)
        end

      :billing ->
        Form.submit(form, params: unsigned_params["form"])
        |> case do
          {:ok, host} ->
            host =
              Ash.load!(
                host,
                [
                  :paystack_subaccount,
                  :paystack_business_name,
                  :paystack_account_number,
                  :paystack_settlement_bank
                ],
                actor: user
              )

            assign(socket, :host, host)
            |> assign(:form, Form.for_update(host, :paystack_subaccount, actor: user))
        end
    end
    |> noreply()
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
end
