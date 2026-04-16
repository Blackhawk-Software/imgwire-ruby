$LOAD_PATH.unshift(File.expand_path("../generated/lib", __dir__))

require "imgwire-generated"

require "imgwire/version"
require "imgwire/client_options"
require "imgwire/client"
require "imgwire/image"
require "imgwire/pagination"
require "imgwire/http/upload_client"
require "imgwire/uploads"
require "imgwire/resources/base_resource"
require "imgwire/resources/images_resource"
require "imgwire/resources/cors_origins_resource"
require "imgwire/resources/custom_domain_resource"
require "imgwire/resources/metrics_resource"
