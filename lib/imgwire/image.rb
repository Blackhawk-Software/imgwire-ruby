require "uri"

module Imgwire
  class Image < ImgwireGenerated::ImageSchema
    PRESETS = %w[thumbnail small medium large].freeze
    ROTATE_ANGLES = [0, 90, 180, 270, 360].freeze
    FORMATS = %w[jpg png avif gif webp].freeze

    RULES = {
      "background" => %w[background bg],
      "crop" => %w[crop],
      "enlarge" => %w[enlarge],
      "format" => %w[format fm],
      "gravity" => %w[gravity],
      "height" => %w[height h],
      "quality" => %w[quality q],
      "rotate" => %w[rotate rot],
      "strip_metadata" => %w[strip_metadata strip],
      "width" => %w[width w],
    }.freeze

    def self.wrap(value)
      return value if value.is_a?(self)
      if value.is_a?(ImgwireGenerated::ImageSchema)
        attributes = ImgwireGenerated::ImageSchema.attribute_map.keys.each_with_object({}) do |attribute, result|
          result[attribute] = value.public_send(attribute)
        end
        return new(attributes)
      end
      return build_from_hash(value.to_hash) if value.respond_to?(:to_hash)

      build_from_hash(value)
    end

    def url(options = {})
      options = symbolize_keys(options)
      path = build_preset_path(options[:preset])
      query = build_query(options.reject { |key, _| key == :preset })

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
      unless PRESETS.include?(preset)
        raise ArgumentError, "Invalid transformation rule value for preset"
      end

      uri = URI.parse(cdn_url)
      slash_index = uri.path.rindex("/")
      prefix = slash_index ? uri.path[0..slash_index] : ""
      file_name = slash_index ? uri.path[(slash_index + 1)..] : uri.path
      dot_index = file_name.rindex(".")
      if dot_index.nil?
        raise ArgumentError, "Cannot apply a preset to a CDN URL without a file extension."
      end

      "#{prefix}#{file_name}@#{preset}"
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
      when "background"
        string = value.to_s.delete_prefix("#")
        raise ArgumentError, "Invalid transformation rule value for #{canonical}" unless string.match?(/\A[\da-fA-F]{6}\z/)

        string.downcase
      when "crop", "gravity"
        value.to_s
      when "enlarge", "strip_metadata"
        value ? "true" : nil
      when "format"
        string = value.to_s
        raise ArgumentError, "Invalid transformation rule value for #{canonical}" unless FORMATS.include?(string)

        string
      when "height", "quality", "width"
        integer = Integer(value)
        raise ArgumentError, "Invalid transformation rule value for #{canonical}" unless integer.positive?

        integer.to_s
      when "rotate"
        integer = Integer(value)
        raise ArgumentError, "Invalid transformation rule value for #{canonical}" unless ROTATE_ANGLES.include?(integer)

        integer.to_s
      else
        value.to_s
      end
    rescue ArgumentError, TypeError
      raise ArgumentError, "Invalid transformation rule value for #{canonical}"
    end
  end
end
