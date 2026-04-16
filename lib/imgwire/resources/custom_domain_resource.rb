# frozen_string_literal: true

module Imgwire
  module Resources
    class CustomDomainResource < BaseResource
      def initialize(api_client)
        super
        @api = ImgwireGenerated::CustomDomainApi.new(api_client)
      end

      def create(payload)
        @api.custom_domain_create(
          coerce_model(ImgwireGenerated::CustomDomainCreateSchema, payload)
        )
      end

      def delete
        @api.custom_domain_delete
      end

      def retrieve
        @api.custom_domain_retrieve
      end

      def test_connection
        @api.custom_domain_test_connection
      end
    end
  end
end
