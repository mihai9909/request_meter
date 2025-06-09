# frozen_string_literal: true

require "spec_helper"
require "pry"

RSpec.describe RequestMeter do
  it "has a version number" do
    expect(RequestMeter::VERSION).not_to be nil
  end

  before do
    RequestMeter.configuration = nil
  end

  context "when configuring RequestMeter" do
    it "configures with a block" do
      expect do
        RequestMeter.configure do |config|
          config.quota_limit = 10
          config.quota_period_seconds = 60
          config.api_key_header = "api-key"
        end
      end.not_to raise_error

      expect(RequestMeter.configuration.quota_limit).to eq(10)
      expect(RequestMeter.configuration.quota_period_seconds).to eq(60)
      expect(RequestMeter.configuration.api_key_header).to eq("api-key")
    end

    it "has a default configuration" do
      RequestMeter.configure do |_|
      end

      expect(RequestMeter.configuration.quota_limit).to eq(1000)
      expect(RequestMeter.configuration.quota_period_seconds).to eq(3600)
      expect(RequestMeter.configuration.api_key_header).to eq("X-API-Key")
    end

    it "allows to execute blocks for dynamic configuration" do
      RequestMeter.configure do |config|
        config.quota_limit = ->(_api_key) { 5 }
        config.quota_period_seconds = ->(_api_key) { 30 }
      end

      expect(RequestMeter.configuration.get_quota_limit("test-api-key")).to eq(5)
      expect(RequestMeter.configuration.get_quota_period_seconds("test-api-key")).to eq(30)
    end
  end
end
