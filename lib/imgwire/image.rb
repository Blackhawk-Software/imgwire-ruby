# frozen_string_literal: true

require 'uri'

module Imgwire
  class Image < ImgwireGenerated::ImageSchema
    PRESETS = %w[thumbnail small medium large].freeze
    ROTATE_ANGLES = [0, 90, 180, 270, 360].freeze
    FORMATS = %w[jpg png avif gif webp auto].freeze

    RULES = {
      'background' => %w[background bg],
      'crop' => %w[crop],
      'enlarge' => %w[enlarge],
      'format' => %w[format fm],
      'gravity' => %w[gravity],
      'height' => %w[height h],
      'quality' => %w[quality q],
      'rotate' => %w[rotate rot],
      'strip_metadata' => %w[strip_metadata strip],
      'width' => %w[width w]
    }.freeze

    def self.wrap(value)
      return value if value.is_a?(self)

      if value.is_a?(ImgwireGenerated::ImageSchema)
        attributes = ImgwireGenerated::ImageSchema.attribute_map.keys.to_h do |attribute|
          [attribute, value.public_send(attribute)]
        end
        return new(attributes)
      end
      return build_from_hash(value.to_hash) if value.respond_to?(:to_hash)

      build_from_hash(value)
    end

    def url(options = {})
      options = symbolize_keys(options)
      path = build_preset_path(options[:preset])
      query = build_query(options.except(:preset))

      uri = URI.parse(cdn_url)
      uri.path = path
      uri.query = query.empty? ? nil : URI.encode_www_form(query.sort_by(&:first))
      uri.to_s
    end

    private

    def symbolize_keys(hash)
      hash.each_with_object({}) do |(key, value), result|
        result[key.to_sym] = value
      end
    end

    def build_preset_path(preset)
      return URI.parse(cdn_url).path if preset.nil?

      preset = preset.to_s
      raise ArgumentError, 'Invalid transformation rule value for preset' unless PRESETS.include?(preset)

      uri = URI.parse(cdn_url)
      "#{uri.path}@#{preset}"
    end

    def build_query(options)
      present = []

      RULES.each do |canonical, aliases|
        matches = aliases.filter_map do |name|
          symbol = name.to_sym
          [symbol, options[symbol]] if options.key?(symbol)
        end

        next if matches.empty?
        raise ArgumentError, "Duplicate transformation rule: #{canonical}" if matches.length > 1

        value = normalize_rule(canonical, matches.first.last)
        present << [canonical, value] unless value.nil?
      end

      present
    end

    def normalize_rule(canonical, value)
      case canonical
      when 'background'
        string = value.to_s.delete_prefix('#')
        unless string.match?(/\A[\da-fA-F]{6}\z/)
          raise ArgumentError,
                "Invalid transformation rule value for #{canonical}"
        end

        string.downcase
      when 'crop', 'gravity'
        value.to_s
      when 'enlarge', 'strip_metadata'
        value ? 'true' : nil
      when 'format'
        string = value.to_s
        unless FORMATS.include?(string)
          raise ArgumentError,
                "Invalid transformation rule value for #{canonical}"
        end

        string
      when 'height', 'quality', 'width'
        integer = Integer(value)
        unless integer.positive?
          raise ArgumentError,
                "Invalid transformation rule value for #{canonical}"
        end

        integer.to_s
      when 'rotate'
        integer = Integer(value)
        unless ROTATE_ANGLES.include?(integer)
          raise ArgumentError,
                "Invalid transformation rule value for #{canonical}"
        end

        integer.to_s
      else
        raise ArgumentError, "Unsupported transformation rule: #{canonical}"
      end
    rescue ArgumentError, TypeError
      raise ArgumentError, "Invalid transformation rule value for #{canonical}"
    end
  end
end
