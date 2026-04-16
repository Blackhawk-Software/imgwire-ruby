lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "imgwire/version"

Gem::Specification.new do |spec|
  spec.name = "imgwire"
  spec.version = Imgwire::VERSION
  spec.authors = ["Blackhawk Software, LLC"]
  spec.email = ["support@imgwire.dev"]

  spec.summary = "Server-side Ruby SDK for the imgwire API."
  spec.description = "Authenticate with a Server API Key, upload files, manage resources, and generate image transformation URLs with imgwire from Ruby applications."
  spec.homepage = "https://github.com/Blackhawk-Software/imgwire-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.files = Dir[
    "AGENTS.md",
    "LICENSE",
    "README.md",
    "CODEGEN_VERSION",
    "lib/**/*.rb",
    "generated/lib/**/*.rb"
  ]
  spec.bindir = "exe"
  spec.require_paths = ["lib", "generated/lib"]

  spec.add_dependency "typhoeus", "~> 1.4"

  spec.add_development_dependency "rubocop", "~> 1.81"
  spec.add_development_dependency "rubocop-rspec", "~> 3.7"
  spec.add_development_dependency "rspec", "~> 3.13"
end
