defmodule Gits.Bucket.Image do
  alias Gits.{Accounts, Storefront}

  @content_type "image/webp"
  @cache_control "public,max-age=86400 s-maxage=86400"

  use Ash.Resource,
    domain: Gits.Bucket,
    data_layer: AshPostgres.DataLayer,
    authorizers: Ash.Policy.Authorizer,
    extensions: [AshArchival.Resource]

  postgres do
    repo Gits.Repo
    table "images"
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]

    create :poster do
      argument :path, :string, allow_nil?: false

      change fn changeset, _ ->
        Ash.Changeset.before_action(changeset, fn changeset ->
          path = Ash.Changeset.get_argument(changeset, :path)
          bucket_name = Application.get_env(:gits, :bucket_name)
          filename = "posters/" <> Nanoid.generate(24) <> ".webp"

          Image.open!(path)
          |> Image.thumbnail!("768x512", fit: :cover)
          |> Image.stream!(
            suffix: ".webp",
            buffer_size: 5_242_880,
            quality: 100
          )
          |> ExAws.S3.upload(
            bucket_name,
            filename,
            content_type: @content_type,
            cache_control: @cache_control
          )
          |> ExAws.request()
          |> case do
            {:ok, _} ->
              Ash.Changeset.force_change_new_attribute(changeset, :name, filename)
          end
        end)
      end
    end
  end

  policies do
    policy action(:read) do
      authorize_if accessing_from(Storefront.Event, :poster)
    end

    policy action(:poster) do
      authorize_if always()
    end

    policy action(:update) do
      authorize_if accessing_from(Storefront.Event, :poster)
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :user, Accounts.User do
      domain Accounts
    end

    belongs_to :host, Accounts.Host do
      domain Accounts
    end

    belongs_to :event, Storefront.Event do
      domain Storefront
    end
  end

  calculations do
    calculate :url, :string, fn records, _ ->
      Enum.map(records, fn record ->
        presigned_url_options = Application.get_env(:gits, :presigned_url_options)
        bucket_name = Application.get_env(:gits, :bucket_name)

        Cachex.fetch(:cache, record.name, fn key ->
          with {:ok, _} <-
                 ExAws.S3.head_object(bucket_name, key) |> ExAws.request(),
               {:ok, signed_url} <-
                 ExAws.Config.new(:s3)
                 |> ExAws.S3.presigned_url(:get, bucket_name, key, presigned_url_options) do
            {:commit, signed_url, expire: :timer.seconds(60)}
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
      end)
    end
  end
end
