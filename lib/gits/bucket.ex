defmodule Gits.Bucket do
  def upload_listing_image(image, account_id, event_id) do
    filename = get_event_filename(account_id, event_id, "listing")
    upload_image(image, filename)
  end

  def upload_feature_image(image, account_id, event_id) do
    filename = get_event_filename(account_id, event_id, "feature")
    upload_image(image, filename)
  end

  defp get_event_filename(account_id, event_id, type) do
    hash_filename("#{account_id}/#{event_id}/#{type}")
  end

  defp hash_filename(filename) do
    :crypto.hash(:sha, filename)
    |> Base.encode16(case: :lower)
  end

  defp upload_image(image, filename) do
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
    get_event_image(account_id, event_id, "listing")
  end

  def get_feature_image_path(account_id, event_id) do
    get_event_image(account_id, event_id, "feature")
  end

  defp get_event_image(account_id, event_id, type) do
    presigned_url_options = Application.get_env(:gits, :presigned_url_options)
    bucket_name = Application.get_env(:gits, :bucket_name)
    filename = get_event_filename(account_id, event_id, type) <> ".jpg"

    with {:ok, _} <- ExAws.S3.head_object(bucket_name, filename) |> ExAws.request(),
         {:ok, url} <-
           ExAws.Config.new(:s3)
           |> ExAws.S3.presigned_url(:get, bucket_name, filename, presigned_url_options) do
      url
    else
      _ ->
        "/images/placeholder.png"
    end
  end
end
