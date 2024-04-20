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
end

