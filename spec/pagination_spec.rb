# frozen_string_literal: true

RSpec.describe Imgwire::Pagination do
  describe Imgwire::Pagination::Metadata do
    it 'parses pagination headers' do
      pagination = described_class.from_headers(
        'X-Total-Count' => '10',
        'X-Page' => '2',
        'X-Limit' => '3',
        'X-Prev-Page' => '1',
        'X-Next-Page' => '3'
      )

      expect(pagination.total_count).to eq(10)
      expect(pagination.page).to eq(2)
      expect(pagination.limit).to eq(3)
      expect(pagination.prev_page).to eq(1)
      expect(pagination.next_page).to eq(3)
    end

    it 'treats null-like header values as missing' do
      pagination = described_class.from_headers(
        'X-Total-Count' => '10',
        'X-Page' => '1',
        'X-Limit' => '25',
        'X-Prev-Page' => 'null',
        'X-Next-Page' => ''
      )

      expect(pagination.total_count).to eq(10)
      expect(pagination.page).to eq(1)
      expect(pagination.limit).to eq(25)
      expect(pagination.prev_page).to be_nil
      expect(pagination.next_page).to be_nil
    end
  end

  describe Imgwire::Pagination::PageEnumerator do
    it 'follows next_page metadata' do
      pages = {
        1 => Imgwire::Pagination::Page.new(
          data: [1, 2],
          pagination: Imgwire::Pagination::Metadata.new(
            total_count: 4,
            page: 1,
            limit: 2,
            prev_page: nil,
            next_page: 2
          )
        ),
        2 => Imgwire::Pagination::Page.new(
          data: [3, 4],
          pagination: Imgwire::Pagination::Metadata.new(
            total_count: 4,
            page: 2,
            limit: 2,
            prev_page: 1,
            next_page: nil
          )
        )
      }

      seen_pages = described_class.new(page: 1, limit: 2) do |page, _limit|
        pages.fetch(page)
      end.to_a

      seen_items = Imgwire::Pagination::ItemEnumerator.new(seen_pages.each).to_a

      expect(seen_pages.length).to eq(2)
      expect(seen_items).to eq([1, 2, 3, 4])
    end
  end
end
