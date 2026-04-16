# frozen_string_literal: true

module Imgwire
  module Resources
    class MetricsResource < BaseResource
      def initialize(api_client)
        super
        @api = ImgwireGenerated::MetricsApi.new(api_client)
      end

      def datasets(interval: nil, page: nil, limit: nil)
        @api.metrics_get_datasets(
          interval: interval,
          page: page,
          limit: limit
        )
      end

      def stats
        @api.metrics_get_stats
      end
    end
  end
end
