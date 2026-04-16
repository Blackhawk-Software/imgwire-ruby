# frozen_string_literal: true

require 'stringio'
require 'tempfile'

RSpec.describe Imgwire::Uploads do
  it 'resolves file object input' do
    Tempfile.create(['image', '.jpg']) do |file|
      file.write('abc')
      file.flush
      file.rewind

      resolved = described_class.resolve(file: file)

      expect(resolved.file_name).to end_with('.jpg')
      expect(resolved.mime_type).to eq('image/jpeg')
      expect(resolved.content_length).to eq(3)
      expect(resolved.io.read).to eq('abc')
    end
  end

  it 'resolves stringio input with explicit metadata' do
    resolved = described_class.resolve(
      file: StringIO.new('payload'),
      file_name: 'image.png'
    )

    expect(resolved.file_name).to eq('image.png')
    expect(resolved.mime_type).to eq('image/png')
    expect(resolved.content_length).to eq(7)
    expect(resolved.io.read).to eq('payload')
  end

  it 'raises when file_name cannot be inferred' do
    io = Object.new
    io.define_singleton_method(:read) { 'payload' }

    expect do
      described_class.resolve(file: io)
    end.to raise_error(ArgumentError, 'Upload file_name could not be inferred')
  end

  it 'raises when content_length cannot be inferred' do
    io = Object.new
    io.define_singleton_method(:read) { 'payload' }

    expect do
      described_class.resolve(file: io, file_name: 'image.jpg')
    end.to raise_error(ArgumentError, 'Upload content_length could not be inferred')
  end
end
