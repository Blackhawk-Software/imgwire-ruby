# frozen_string_literal: true

require 'stringio'

RSpec.describe Imgwire::Resources::ImagesResource do
  let(:api_client) { ImgwireGenerated::ApiClient.new(ImgwireGenerated::Configuration.new) }
  let(:upload_http_client) { instance_double(Imgwire::HTTP::UploadClient) }
  let(:options) do
    Imgwire::ClientOptions.new(
      api_key: 'sk_test',
      base_url: 'https://api.example.com',
      environment_id: nil,
      timeout: 5,
      max_retries: 2,
      backoff_factor: 0.1,
      upload_http_client: upload_http_client
    )
  end

  it 'parses pagination headers for list responses' do
    resource = described_class.new(api_client, options)
    fake_api = Object.new
    fake_image = ImgwireGenerated::ImageSchema.build_from_hash(
      'cdn_url' => 'https://cdn.imgwire.dev/example.jpg',
      'created_at' => '2026-04-14T00:00:00Z',
      'custom_metadata' => {},
      'deleted_at' => nil,
      'environment_id' => nil,
      'exif_data' => {},
      'extension' => 'jpg',
      'hash_sha256' => nil,
      'height' => 100,
      'id' => 'img_1',
      'idempotency_key' => nil,
      'mime_type' => 'image/jpeg',
      'original_filename' => 'example.jpg',
      'processed_metadata_at' => nil,
      'purpose' => nil,
      'size_bytes' => 100,
      'status' => 'READY',
      'updated_at' => '2026-04-14T00:00:00Z',
      'upload_token_id' => nil,
      'width' => 100
    )
    fake_api.define_singleton_method(:images_list_with_http_info) do |page:, limit:|
      [
        [fake_image],
        200,
        {
          'X-Total-Count' => '3',
          'X-Page' => page.to_s,
          'X-Limit' => limit.to_s,
          'X-Next-Page' => '2'
        }
      ]
    end

    resource.instance_variable_set(:@api, fake_api)
    result = resource.list(page: 1, limit: 25)

    expect(result.data.first).to be_a(Imgwire::Image)
    expect(result.pagination.total_count).to eq(3)
    expect(result.pagination.next_page).to eq(2)
  end

  it 'uploads IO values using the upload HTTP client' do
    resource = described_class.new(api_client, options)
    image = Imgwire::Image.build_from_hash(
      'cdn_url' => 'https://cdn.imgwire.dev/example.jpg',
      'created_at' => '2026-04-14T00:00:00Z',
      'custom_metadata' => {},
      'deleted_at' => nil,
      'environment_id' => nil,
      'exif_data' => {},
      'extension' => 'jpg',
      'hash_sha256' => nil,
      'height' => 100,
      'id' => 'img_1',
      'idempotency_key' => nil,
      'mime_type' => 'image/jpeg',
      'original_filename' => 'example.jpg',
      'processed_metadata_at' => nil,
      'purpose' => nil,
      'size_bytes' => 100,
      'status' => 'READY',
      'updated_at' => '2026-04-14T00:00:00Z',
      'upload_token_id' => nil,
      'width' => 100
    )
    response = Struct.new(:upload_url, :image).new('https://uploads.example.com', image)
    captured_payload = nil
    captured_upload_token = nil

    resource.define_singleton_method(:create) do |payload, upload_token: nil|
      captured_payload = payload
      captured_upload_token = upload_token
      response
    end

    expect(upload_http_client).to receive(:put) do |url, resolved, timeout:, max_retries:, backoff_factor:|
      expect(url).to eq('https://uploads.example.com')
      expect(resolved.file_name).to eq('file.jpg')
      expect(resolved.mime_type).to eq('image/jpeg')
      expect(resolved.content_length).to eq(3)
      expect(timeout).to eq(5)
      expect(max_retries).to eq(2)
      expect(backoff_factor).to eq(0.1)
    end

    result = resource.upload(
      file: StringIO.new('abc'),
      file_name: 'file.jpg'
    )

    expect(captured_payload[:file_name]).to eq('file.jpg')
    expect(captured_payload[:mime_type]).to eq('image/jpeg')
    expect(captured_payload[:content_length]).to eq(3)
    expect(captured_upload_token).to be_nil
    expect(result).to eq(image)
  end
end
