defmodule Gits.PaystackApi do
  def list_banks!() do
    {:ok, banks} = list_banks()
    banks
  end

  def list_banks do
    options = Application.get_env(:gits, :paystack_api_options)

    Req.new(options)
    |> Req.request(url: "/bank?currency=zar")
    |> case do
      {:ok, %Req.Response{body: %{"data" => raw_list, "status" => true}}} ->
        {:ok, raw_bank_list_to_formatted(raw_list)}
    end
  end

  defp raw_bank_list_to_formatted(list) do
    Enum.filter(list, fn item -> item["active"] == true end)
    |> Enum.map(fn %{"id" => id, "name" => name, "code" => code} ->
      %{id: id, name: name, code: code}
    end)
  end

  def create_subaccount(business_name, account_number, settlement_bank) do
    options = Application.get_env(:gits, :paystack_api_options)

    Req.new(options)
    |> Req.post(
      url: "/subaccount",
      json: %{
        business_name: business_name,
        account_number: account_number,
        settlement_bank: settlement_bank,
        percentage_charge: 1
      }
    )
    |> case do
      {:ok, %Req.Response{body: %{"data" => subaccount, "status" => true}}} ->
        {:ok, extract_subaccount(subaccount)}

      _ ->
        :error
    end
  end

  def update_subaccount(subaccount_code, business_name, account_number, settlement_bank) do
    options = Application.get_env(:gits, :paystack_api_options)

    Req.new(options)
    |> Req.put(
      url: "/subaccount/#{subaccount_code}",
      json: %{
        business_name: business_name,
        account_number: account_number,
        settlement_bank: settlement_bank
      }
    )
    |> case do
      {:ok, %Req.Response{body: %{"data" => subaccount, "status" => true}}} ->
        {:ok, extract_subaccount(subaccount)}
    end
  end

  def fetch_subaccount(subaccount_code) do
    if is_nil(subaccount_code) do
      {:error, :no_code_provided}
    else
      options = Application.get_env(:gits, :paystack_api_options)

      Req.new(options)
      |> Req.request(url: "/subaccount/#{subaccount_code}")
      |> case do
        {:ok, %Req.Response{body: %{"data" => subaccount, "status" => true}}} ->
          {:ok, extract_subaccount(subaccount)}
      end
    end
  end

  def create_transaction(subaccount_code, customer_email, price_in_cents, callback_url) do
    options = Application.get_env(:gits, :paystack_api_options)

    Req.new(options)
    |> Req.post(
      url: "/transaction/initialize",
      json: %{
        subaccount: subaccount_code,
        email: customer_email,
        amount: price_in_cents,
        callback_url: callback_url,
        bearer: "subaccount"
      }
    )
    |> case do
      {:ok, %Req.Response{body: %{"data" => transaction, "status" => true}}} ->
        {:ok,
         %{
           reference: transaction["reference"],
           authorization_url: transaction["authorization_url"]
         }}
    end
  end

  def verify_transaction(reference) do
    options = Application.get_env(:gits, :paystack_api_options)

    Req.new(options)
    |> Req.request(url: "/transaction/verify/#{reference}")
    |> case do
      {:ok, %Req.Response{body: %{"data" => transaction, "status" => true}}} ->
        case transaction do
          %{"status" => "abandoned"} -> {:ok, %{status: :abandoned}}
          %{"status" => "failed", "gateway_response" => "Declined"} -> {:ok, %{status: :declined}}
          %{"status" => "ongoing"} -> {:ok, %{status: :ongoing}}
          %{"status" => "success"} -> {:ok, %{status: :success}}
        end
    end
  end

  defp extract_subaccount(subaccount) do
    %{
      business_name: subaccount["business_name"],
      account_number: subaccount["account_number"],
      subaccount_code: subaccount["subaccount_code"],
      percentage_charge: subaccount["percentage_charge"],
      settlement_bank: fetch_settlement_bank_by_id(subaccount["bank"])
    }
  end

  defp fetch_settlement_bank_by_id(id) do
    Gits.PaystackApi.list_banks()
    |> case do
      {:ok, list} -> list
    end
    |> Enum.find(fn %{id: found} -> id == found end)
    |> case do
      %{code: code} -> code
    end
  end
end
