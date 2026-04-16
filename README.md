# `imgwire`

`imgwire` is the server-side Ruby SDK for the imgwire API.

Use it in Rails apps, workers, jobs, and other backend runtimes to authenticate with a Server API Key, upload files from Ruby IO objects, manage server-side resources, and generate image transformation URLs without rebuilding imgwire request plumbing yourself.

## Installation

```bash
gem install imgwire
```

Or with Bundler:

```ruby
gem "imgwire"
```

## Quick Start

```ruby
require "imgwire"

client = Imgwire::Client.new(api_key: "sk_...")

File.open("hero.jpg", "rb") do |file|
  image = client.images.upload(file: file)

  puts image.id
  puts image.url(preset: "thumbnail", width: 300, height: 300)
end
```

## Client Setup

```ruby
client = Imgwire::Client.new(api_key: "sk_...")
```

Optional configuration:

```ruby
client = Imgwire::Client.new(
  api_key: "sk_...",
  base_url: "https://api.imgwire.dev",
  environment_id: "env_123",
  timeout: 10,
  max_retries: 2,
  backoff_factor: 0.25
)
```

## Resources

The handwritten Ruby surface currently wraps these generated server resources:

- `client.images`
- `client.custom_domain`
- `client.cors_origins`
- `client.metrics`

### Uploads

The image upload helper accepts `File`, `IO`, `StringIO`, and `Tempfile` inputs:

```ruby
file = File.open("file.jpg", "rb")
image = client.images.upload(file: file)
```

Explicit metadata is also supported:

```ruby
image = client.images.upload(
  file: StringIO.new(binary_data),
  file_name: "file.png",
  mime_type: "image/png",
  content_length: binary_data.bytesize
)
```

### Pagination

```ruby
page = client.images.list(page: 1, limit: 25)

client.images.list_pages(limit: 100).each do |result|
  puts result.pagination.page
  puts result.data.length
end

client.images.list_all(limit: 100).each do |image|
  puts image.id
end
```

### Image URL Transformations

Image-returning endpoints return `Imgwire::Image` values with a `url(...)` helper:

```ruby
image = client.images.retrieve("img_123")

puts image.url(
  preset: "thumbnail",
  width: 300,
  height: 300,
  format: "webp",
  quality: 80
)
```

## Generation

From a clean checkout:

```bash
yarn install --frozen-lockfile
yarn generate
bundle install
bundle exec rspec
```

Or with the repository `Makefile`:

```bash
make install
make generate
make test
```

The generation pipeline:

```text
raw OpenAPI
-> @imgwire/codegen-core target "ruby"
-> openapi/sdk.openapi.json
-> OpenAPI Generator ruby client
-> generated/
-> postprocess cleanup
-> CODEGEN_VERSION update
```
