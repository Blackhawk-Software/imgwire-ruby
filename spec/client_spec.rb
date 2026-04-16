RSpec.describe Imgwire::Client do
  it "sets default headers and base URL configuration" do
    client = described_class.new(
      api_key: "sk_test",
      base_url: "https://api.example.com",
      environment_id: "env_123",
      timeout: 12,
      max_retries: 3,
    )

    expect(client.api_client.config.base_url).to eq("https://api.example.com")
    expect(client.api_client.default_headers["Authorization"]).to eq("Bearer sk_test")
    expect(client.api_client.default_headers["X-Environment-Id"]).to eq("env_123")
    expect(client.images).to be_a(Imgwire::Resources::ImagesResource)
  end
end
