# frozen_string_literal: true

require 'forwardable'

module Imgwire
  module Pagination
    Metadata = Struct.new(
      :total_count,
      :page,
      :limit,
      :prev_page,
      :next_page,
      keyword_init: true
    ) do
      def self.from_headers(headers)
        normalized = {}
        headers.each do |key, value|
          normalized[key.to_s.downcase] = value
        end

        new(
          total_count: parse_int(normalized['x-total-count']),
          page: parse_int(normalized['x-page']),
          limit: parse_int(normalized['x-limit']),
          prev_page: parse_int(normalized['x-prev-page']),
          next_page: parse_int(normalized['x-next-page'])
        )
      end

      def self.parse_int(value)
        return nil if value.nil?

        normalized = value.to_s.strip.downcase
        return nil if normalized.empty? || normalized == 'null' || normalized == 'none'

        normalized.to_i
      end
    end

    Page = Struct.new(:data, :pagination, keyword_init: true)

    class PageEnumerator
      include Enumerable

      def initialize(page:, limit:, &loader)
        @page = page
        @limit = limit
        @loader = loader
      end

      def each
        return enum_for(:each) unless block_given?

        current_page = @page
        current_limit = @limit

        while current_page
          result = @loader.call(current_page, current_limit)
          yield result
          current_limit = result.pagination.limit || current_limit
          current_page = result.pagination.next_page
        end
      end
    end

    class ItemEnumerator
      include Enumerable

      def initialize(page_enumerator)
        @page_enumerator = page_enumerator
      end

      def each(&block)
        return enum_for(:each) unless block_given?

        @page_enumerator.each do |page|
          page.data.each(&block)
        end
      end
    end
  end
end
