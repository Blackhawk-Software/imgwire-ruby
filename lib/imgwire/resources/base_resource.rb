# frozen_string_literal: true

module Imgwire
  module Resources
    class BaseResource
      def initialize(api_client)
        @api_client = api_client
      end

      private

      def coerce_model(model_type, value)
        return value if value.is_a?(model_type)
        return model_type.build_from_hash(value) if value.is_a?(Hash)

        raise ArgumentError, "Expected #{model_type} or Hash"
      end

      def to_page(response)
        data, = response
        _data, _status, headers = response
        Pagination::Page.new(
          data: data,
          pagination: Pagination::Metadata.from_headers(headers || {})
        )
      end
    end
  end
end
