require "net/http"
require "uri"

module Imgwire
  module HTTP
    class UploadClient
      RETRYABLE_ERRORS = [
        Errno::ECONNRESET,
        Errno::ETIMEDOUT,
        IOError,
        Net::OpenTimeout,
        Net::ReadTimeout,
      ].freeze

      def put(url, upload, timeout:, max_retries:, backoff_factor:)
        uri = URI.parse(url)
        attempts = 0

        begin
          attempts += 1
          upload.rewind if upload.respond_to?(:rewind)

          request = Net::HTTP::Put.new(uri)
          request["Content-Length"] = upload.content_length.to_s
          request["Content-Type"] = upload.mime_type if upload.mime_type
          request.body_stream = upload.io
          request.content_length = upload.content_length

          Net::HTTP.start(
            uri.host,
            uri.port,
            use_ssl: uri.scheme == "https",
            open_timeout: timeout,
            read_timeout: timeout,
            write_timeout: timeout,
          ) do |http|
            response = http.request(request)
            return response if response.is_a?(Net::HTTPSuccess)

            raise "Upload failed with status #{response.code}: #{response.body}"
          end
        rescue *RETRYABLE_ERRORS => error
          raise error if attempts > max_retries + 1

          sleep(backoff_factor * (2**(attempts - 1)))
          retry
        end
      end
    end
  end
end
