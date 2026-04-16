# frozen_string_literal: true

module Imgwire
  module Resources
    class ImagesResource < BaseResource
      def initialize(api_client, options)
        super(api_client)
        @api = ImgwireGenerated::ImagesApi.new(api_client)
        @options = options
      end

      def bulk_delete(payload)
        @api.images_bulk_delete(
          coerce_model(ImgwireGenerated::BulkDeleteImagesSchema, payload)
        )
      end

      def create(payload, upload_token: nil)
        response = @api.images_create(
          coerce_model(ImgwireGenerated::StandardUploadCreateSchema, payload),
          upload_token: upload_token
        )
        response.image = Image.wrap(response.image)
        response
      end

      def create_bulk_download_job(payload)
        @api.images_create_bulk_download_job(
          coerce_model(ImgwireGenerated::ImageDownloadJobCreateSchema, payload)
        )
      end

      def create_upload_token
        @api.images_create_upload_token
      end

      def delete(image_id)
        @api.images_delete(image_id)
      end

      def list(page: nil, limit: nil)
        page_result = to_page(@api.images_list_with_http_info(page: page, limit: limit))
        page_result.data = page_result.data.map { |image| Image.wrap(image) }
        page_result
      end

      def list_pages(page: 1, limit: nil)
        Pagination::PageEnumerator.new(page: page, limit: limit) do |current_page, current_limit|
          list(page: current_page, limit: current_limit)
        end
      end

      def list_all(page: 1, limit: nil)
        Pagination::ItemEnumerator.new(list_pages(page: page, limit: limit))
      end

      def retrieve(image_id)
        Image.wrap(@api.images_retrieve(image_id))
      end

      def retrieve_bulk_download_job(image_download_job_id)
        @api.images_retrieve_bulk_download_job(image_download_job_id)
      end

      def upload(
        file:,
        file_name: nil,
        mime_type: nil,
        content_length: nil,
        custom_metadata: nil,
        hash_sha256: nil,
        idempotency_key: nil,
        purpose: nil
      )
        resolved = Uploads.resolve(
          file: file,
          file_name: file_name,
          mime_type: mime_type,
          content_length: content_length
        )

        created = create(
          {
            content_length: resolved.content_length,
            custom_metadata: custom_metadata,
            file_name: resolved.file_name,
            hash_sha256: hash_sha256,
            idempotency_key: idempotency_key,
            mime_type: resolved.mime_type,
            purpose: purpose
          }
        )

        @options.upload_http_client.put(
          created.upload_url,
          resolved,
          timeout: @options.timeout,
          max_retries: @options.max_retries,
          backoff_factor: @options.backoff_factor
        )

        created.image
      end
    end
  end
end
