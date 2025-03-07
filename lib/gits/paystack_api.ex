defmodule Gits.PaystackApi do
  def list_banks!(:cache) do
    Cachex.fetch(:cache, "banks", fn _ ->
      list_banks()
      |> case do
        {:ok, banks} -> {:commit, banks}
        _ -> {:ignore, nil}
      end
    end)
    |> case do
      {:ok, banks} -> banks
      {:commit, banks} -> banks
    end
  end

  def list_banks! do
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
        percentage_charge: 5
      }
    )
    |> case do
      {:ok, %Req.Response{body: %{"data" => subaccount, "status" => true}}} ->
        {:ok, extract_subaccount(subaccount)}

      _ ->
        :error
    end
  end

  def update_subaccount(subaccount_code, business_name, account_number, settlement_bank, :cache) do
    update_subaccount(subaccount_code, business_name, account_number, settlement_bank)
    |> case do
      {:ok, subaccount} -> Cachex.put(:cache, subaccount_code, subaccount)
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

  def fetch_subaccount(subaccount_code, :cache) do
    Cachex.fetch(:cache, subaccount_code, fn key ->
      fetch_subaccount(key)
      |> case do
        {:ok, subaccount} -> {:commit, subaccount}
        _ -> {:ignore, nil}
      end
    end)
    |> case do
      {:ok, subaccount} -> {:ok, subaccount}
      {:commit, subaccount} -> {:ok, subaccount}
      {:ignore, nil} -> nil
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

        _ ->
          :error
      end
    end
  end

  def create_transaction(subaccount_code, customer_email, price_in_cents) do
    options = Application.get_env(:gits, :paystack_api_options)

    base_url = Application.get_env(:gits, :paystack) |> Keyword.get(:callback_url_base)

    Req.new(options)
    |> Req.post(
      url: "/transaction/initialize",
      json: %{
        subaccount: subaccount_code,
        email: customer_email,
        amount: price_in_cents,
        callback_url: "#{base_url}/orders/paystack/callback",
        metadata: %{
          cancel_action: "#{base_url}/orders/paystack/callback/cancel"
        }
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
          %{"status" => "abandoned"} ->
            {:ok, %{status: :abandoned}}

          %{"status" => "failed", "gateway_response" => "Declined"} ->
            {:ok, %{status: :declined}}

          %{"status" => "ongoing"} ->
            {:ok, %{status: :ongoing}}

          %{"status" => "reversed"} ->
            {:ok, %{status: :refunded}}

          %{"status" => "success"} ->
            {:ok, %{status: :success}, transaction}
        end
    end
  end

  def get_transaction_status(reference) do
    options = Application.get_env(:gits, :paystack_api_options)

    Req.new(options)
    |> Req.request(url: "/transaction/verify/#{reference}")
    |> case do
      {:ok, %Req.Response{body: %{"data" => transaction, "status" => true}}} ->
        case transaction do
          %{"status" => "abandoned"} ->
            {:ok, :abandoned}

          %{"status" => "failed", "gateway_response" => "Declined"} ->
            {:ok, :declined}

          %{"status" => "ongoing"} ->
            {:ok, :ongoing}

          %{"status" => "reversed"} ->
            {:ok, :reversed}

          %{"status" => "success"} ->
            {:ok, :success}
        end
    end
  end

  def create_refund(reference, amount) do
    options = Application.get_env(:gits, :paystack_api_options)

    Req.new(options)
    |> Req.post(
      url: "/refund",
      json: %{
        transaction: reference,
        amount: amount
      }
    )
    |> case do
      {:ok, %Req.Response{body: %{"data" => refund, "status" => true}}} ->
        {:ok, refund}
    end
  end

  def create_full_refund(reference, reason) do
    options = Application.get_env(:gits, :paystack_api_options)

    Req.new(options)
    |> Req.post(
      url: "/refund",
      json: %{
        transaction: reference,
        merchant_note: reason
      }
    )
    |> case do
      {:ok, %Req.Response{body: %{"data" => refund, "status" => true}}} ->
        {:ok, refund}
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
