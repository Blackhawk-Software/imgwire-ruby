module Imgwire
  module Resources
    class CorsOriginsResource < BaseResource
      def initialize(api_client)
        super(api_client)
        @api = ImgwireGenerated::CorsOriginsApi.new(api_client)
      end

      def create(payload)
        @api.cors_origins_create(
          coerce_model(ImgwireGenerated::CorsOriginCreateSchema, payload),
        )
      end

      def delete(cors_origin_id)
        @api.cors_origins_delete(cors_origin_id)
      end

      def list(page: nil, limit: nil)
        to_page(@api.cors_origins_list_with_http_info(page: page, limit: limit))
      end

      def list_pages(page: 1, limit: nil)
        Pagination::PageEnumerator.new(page: page, limit: limit) do |current_page, current_limit|
          list(page: current_page, limit: current_limit)
        end
      end

      def list_all(page: 1, limit: nil)
        Pagination::ItemEnumerator.new(list_pages(page: page, limit: limit))
      end

      def retrieve(cors_origin_id)
        @api.cors_origins_retrieve(cors_origin_id)
      end

      def update(cors_origin_id, payload)
        @api.cors_origins_update(
          cors_origin_id,
          coerce_model(ImgwireGenerated::CorsOriginUpdateSchema, payload),
        )
      end
    end
  end
end
