# frozen_string_literal: true

RSpec.describe Imgwire::Image do
  def build_image
    described_class.build_from_hash(
      'can_upload' => true,
      'cdn_url' => 'https://cdn.imgwire.dev/example',
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
      'is_directly_deliverable' => true,
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
  end

  it 'builds transformed URLs with presets and canonical params' do
    image = build_image

    expect(
      image.url(preset: 'thumbnail', bg: '#ffffff', h: 150, rot: 90, w: 150)
    ).to eq(
      'https://cdn.imgwire.dev/example@thumbnail?background=ffffff&height=150&rotate=90&width=150'
    )
  end

  it 'omits false boolean flags' do
    image = build_image

    expect(
      image.url(enlarge: false, strip_metadata: true)
    ).to eq(
      'https://cdn.imgwire.dev/example?strip_metadata=true'
    )
  end

  it 'allows auto as an output format' do
    image = build_image

    expect(image.url(format: 'auto')).to eq('https://cdn.imgwire.dev/example?format=auto')
  end

  it 'rejects duplicate aliases' do
    image = build_image

    expect { image.url(width: 100, w: 200) }.to raise_error(
      ArgumentError,
      'Duplicate transformation rule: width'
    )
  end

  it 'rejects invalid rotate values' do
    image = build_image

    expect { image.url(rotate: 45) }.to raise_error(
      ArgumentError,
      'Invalid transformation rule value for rotate'
    )
  end
end
