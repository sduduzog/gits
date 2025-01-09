defmodule Gits.Bucket do
  def get_image_url(nil) do
    "/images/placeholder.png"
  end

  def get_image_url(filename) do
    presigned_url_options = Application.get_env(:gits, :presigned_url_options)

    bucket_name = Application.get_env(:gits, :bucket_name)

    with {:ok, _} <-
           ExAws.S3.head_object(bucket_name, filename) |> ExAws.request(),
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
