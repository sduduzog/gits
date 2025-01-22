defmodule Gits.Bucket do
  def get_image_url(nil), do: "/images/placeholder.png"

  def get_image_url(filename) do
    presigned_url_options = Application.get_env(:gits, :presigned_url_options)
    bucket_name = Application.get_env(:gits, :bucket_name)

    Cachex.fetch(:cache, filename, fn key ->
      with {:ok, _} <-
             ExAws.S3.head_object(bucket_name, key) |> ExAws.request(),
           {:ok, signed_url} <-
             ExAws.Config.new(:s3)
             |> ExAws.S3.presigned_url(:get, bucket_name, key, presigned_url_options) do
        {:commit, signed_url, expire: :timer.seconds(30)}
      else
        _ ->
          {:ignore, "/images/placeholder.png"}
      end
    end)
    |> case do
      {:commit, url, _} -> url
      {:ignore, url} -> url
      {:ok, url} -> url
    end
  end

  def upload_image(image) do
    bucket_name = Application.get_env(:gits, :bucket_name)

    filename = Nanoid.generate(24) <> ".jpg"

    image
    |> ExAws.S3.upload(
      bucket_name,
      filename,
      content_type: "image/jpeg",
      cache_control: "public,max-age=3600 s-maxage=7200"
    )
    |> ExAws.request()
    |> case do
      {:ok, _} -> {:ok, filename}
    end
  end
end
