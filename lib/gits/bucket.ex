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
      content_type: "image/jpeg",
      cache_control: "public,max-age=3600"
    )
    |> ExAws.request()
  end

  def get_listing_image_path(account_id, event_id) do
    "/assets/" <> get_event_filename(account_id, event_id, "listing")
  end

  def get_feature_image_path(account_id, event_id) do
    "/assets/" <> get_event_filename(account_id, event_id, "feature")
  end

  def feature_image_exists?(account_id, event_id) do
    filename = get_event_filename(account_id, event_id, "feature")

    bucket_name = Application.get_env(:gits, :bucket_name)
    filename = "#{filename}.jpg"

    ExAws.S3.head_object(bucket_name, filename)
    |> ExAws.request()
    |> case do
      {:ok, _} -> true
      _ -> false
    end
  end

  def get_image_url(hash) do
    presigned_url_options = Application.get_env(:gits, :presigned_url_options)

    bucket_name = Application.get_env(:gits, :bucket_name)
    filename = "#{hash}.jpg"

    with {:ok, _} <- ExAws.S3.head_object(bucket_name, filename) |> ExAws.request(),
         {:ok, signed_url} <-
           ExAws.Config.new(:s3)
           |> ExAws.S3.presigned_url(:get, bucket_name, filename, presigned_url_options) do
      signed_url
    else
      _ ->
        "/images/placeholder.png"
    end
  end
end
