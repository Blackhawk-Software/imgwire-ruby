module Imgwire
  ClientOptions = Struct.new(
    :api_key,
    :base_url,
    :environment_id,
    :timeout,
    :max_retries,
    :backoff_factor,
    :upload_http_client,
    keyword_init: true,
  )
end
