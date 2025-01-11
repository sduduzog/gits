defmodule Gits.Bucket do
  def get_image_url(nil) do
    {:ok, "/images/placeholder.png"}
  end

  def get_image_url(filename) do
    presigned_url_options = Application.get_env(:gits, :presigned_url_options)
    bucket_name = Application.get_env(:gits, :bucket_name)

    Cachex.fetch(:cache, filename, fn key ->
      with {:ok, _} <-
             ExAws.S3.head_object(bucket_name, key) |> ExAws.request(),
           {:ok, signed_url} <-
             ExAws.Config.new(:s3)
             |> ExAws.S3.presigned_url(:get, bucket_name, key, presigned_url_options) do
        {:ok, signed_url}
      else
        _ ->
          {:ignore, "/images/placeholder.png"}
      end
    end)
    |> case do
      {_, url} -> url
    end
  end

  def get_image_url!(filename) do
    {:ok, url} = get_image_url(filename)
    url
  end
end
