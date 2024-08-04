defmodule Gits.Bucket do
  def upload_listing_image(image, account_id, event_id) do
    upload(image, "#{account_id}/#{event_id}/listing")
  end

  def upload_feature_image(image, account_id, event_id) do
    upload(image, "#{account_id}/#{event_id}/feature")
  end

  defp upload(image, filename) do
    bucket_name = Application.get_env(:gits, :bucket_name)

    ExAws.S3.upload(
      image,
      bucket_name,
      "#{filename}.jpg",
      content_type: "image/jpeg"
    )
    |> ExAws.request!()
  end

  def get_listing_image_path(account_id, event_id) do
    get_image(account_id, event_id, "listing")
  end

  def get_feature_image_path(account_id, event_id) do
    get_image(account_id, event_id, "feature")
  end

  defp get_image(account_id, event_id, name) do
    bucket_name = Application.get_env(:gits, :bucket_name)
    filename = "#{account_id}/#{event_id}/#{name}.jpg"

    ExAws.S3.head_object(bucket_name, filename)
    |> ExAws.request()
    |> case do
      {:ok, _} -> "/bucket/#{filename}"
      _ -> "/images/placeholder.png"
    end
  end
end
