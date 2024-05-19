defmodule Gits.PaystackApi do
  def list_banks do
    options = Application.get_env(:gits, :paystack_api_options)

    Req.new(options)
    []
  end

  def transform_list_banks_response do
    []
  end
end
