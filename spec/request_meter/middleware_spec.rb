# frozen_string_literal: true

require "spec_helper"
require "rack/mock"
require "redis"
require "json"

RSpec.describe RequestMeter::Middleware do
  let(:app) do
    ->(_env) { [200, { "Content-Type" => "text/plain" }, ["OK"]] }
  end

  let(:cache_client) { Redis.new(url: ENV["REDIS_URL"] || "redis://localhost:6379/1") }
  let(:middleware) { described_class.new(app) }

  let(:api_key) { "test-api-key" }
  let(:header_key) { "HTTP_#{RequestMeter.configuration.api_key_header.upcase.gsub("-", "_")}" }

  before do
    # Reset config before each test
    RequestMeter.configure do |config|
      config.quota_limit = 2
      config.quota_period_seconds = 60
      config.api_key_header = "X-API-Key"
      config.cache_client = cache_client
    end
    cache_client.flushdb
  end

  def request(env_headers = {})
    env = Rack::MockRequest.env_for("/", env_headers)
    middleware.call(env)
  end

  it "returns 400 if API key is missing" do
    status, _, body = request
    expect(status).to eq(400)
    expect(JSON.parse(body.first)["error"]).to eq("API key is required")
  end

  it "allows request if under quota" do
    2.times do
      status, _headers, body = request(header_key => api_key)
      expect(status).to eq(200)
      expect(body.first).to eq("OK")
    end
  end

  it "returns 429 if over quota" do
    3.times { request(header_key => api_key) }
    status, headers, body = request(header_key => api_key)

    expect(status).to eq(429)
    expect(headers["Retry-After"]).to be_a(String)
    expect(body.first).to include("Quota exceeded. Try again in")
  end

  it "resets quota after expiration" do
    2.times { request(header_key => api_key) }
    expect(cache_client.get("request_meter:#{api_key}")).to eq("2")

    cache_client.expire("request_meter:#{api_key}", 0) # simulate expiration
    status, _headers, body = request(header_key => api_key)

    expect(status).to eq(200)
    expect(body.first).to eq("OK")
  end

  context "when cache client is missing" do
    before do
      RequestMeter.configuration.cache_client = nil
    end

    it "raises MissingCacheClientError" do
      expect do
        described_class.new(app)
      end.to raise_error(RequestMeter::MissingCacheClientError, "Cache client is required")
    end
  end
end
