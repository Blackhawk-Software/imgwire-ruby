require "pathname"
require "stringio"
require "tempfile"

module Imgwire
  module Uploads
    DEFAULT_CONTENT_TYPE = "application/octet-stream"
    MIME_TYPES = {
      ".avif" => "image/avif",
      ".gif" => "image/gif",
      ".jpeg" => "image/jpeg",
      ".jpg" => "image/jpeg",
      ".png" => "image/png",
      ".webp" => "image/webp",
    }.freeze

    ResolvedUpload = Struct.new(
      :io,
      :file_name,
      :mime_type,
      :content_length,
      keyword_init: true,
    ) do
      def rewind
        io.rewind if io.respond_to?(:rewind)
      end
    end

    module_function

    def resolve(file:, file_name: nil, mime_type: nil, content_length: nil)
      io = file
      inferred_file_name = file_name || infer_file_name(file)
      inferred_mime_type = mime_type || infer_mime_type(inferred_file_name)
      inferred_content_length = content_length || infer_content_length(file)

      unless io.respond_to?(:read)
        raise ArgumentError, "Upload file must respond to #read"
      end

      if inferred_file_name.nil? || inferred_file_name.empty?
        raise ArgumentError, "Upload file_name could not be inferred"
      end

      if inferred_content_length.nil?
        raise ArgumentError, "Upload content_length could not be inferred"
      end

      ResolvedUpload.new(
        io: io,
        file_name: inferred_file_name,
        mime_type: inferred_mime_type || DEFAULT_CONTENT_TYPE,
        content_length: inferred_content_length,
      )
    end

    def infer_file_name(file)
      return File.basename(file.path) if file.respond_to?(:path) && file.path
      return "upload.bin" if file.is_a?(StringIO)

      nil
    end

    def infer_mime_type(file_name)
      return nil unless file_name

      MIME_TYPES[File.extname(file_name).downcase]
    end

    def infer_content_length(file)
      return file.size if file.respond_to?(:size) && file.size

      if file.respond_to?(:path) && file.path
        return File.size(file.path)
      end

      return file.string.bytesize if file.is_a?(StringIO)

      nil
    end
  end
end
