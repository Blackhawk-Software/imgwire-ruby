require "uri"

module Imgwire
  class Client
    attr_reader :api_client, :options, :images, :custom_domain, :cors_origins, :metrics

    def initialize(
      api_key:,
      base_url: "https://api.imgwire.dev",
      environment_id: nil,
      timeout: 30,
      max_retries: 2,
      backoff_factor: 0.5,
      upload_http_client: nil
    )
      @options = ClientOptions.new(
        api_key: api_key,
        base_url: base_url.sub(%r{/\z}, ""),
        environment_id: environment_id,
        timeout: timeout,
        max_retries: max_retries,
        backoff_factor: backoff_factor,
        upload_http_client: upload_http_client || HTTP::UploadClient.new,
      )

      configuration = ImgwireGenerated::Configuration.new
      apply_base_url(configuration, @options.base_url)
      configuration.timeout = @options.timeout

      @api_client = ImgwireGenerated::ApiClient.new(configuration)
      @api_client.default_headers["Authorization"] = "Bearer #{api_key}"
      @api_client.default_headers["User-Agent"] = "imgwire-ruby/#{Imgwire::VERSION}"
      if environment_id
        @api_client.default_headers["X-Environment-Id"] = environment_id
      end

      @images = Resources::ImagesResource.new(@api_client, @options)
      @custom_domain = Resources::CustomDomainResource.new(@api_client)
      @cors_origins = Resources::CorsOriginsResource.new(@api_client)
      @metrics = Resources::MetricsResource.new(@api_client)
    end

    private

    def apply_base_url(configuration, base_url)
      uri = URI.parse(base_url)
      configuration.scheme = uri.scheme
      configuration.host = uri.host.to_s
      configuration.base_path = uri.path
    end
  end
end
