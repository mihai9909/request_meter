# frozen_string_literal: true

require_relative "request_meter/version"
require "request_meter/middleware"
require "request_meter/configuration"

module RequestMeter
  class MissingCacheClientError < StandardError; end

  class << self
    # @return [RequestMeter::Configuration] current configuration instance
    attr_accessor :configuration
  end

  # Configure the RequestMeter settings.
  #
  # Yields the configuration object to the given block.
  #
  # @yieldparam config [RequestMeter::Configuration] the configuration object
  # @return [void]
  #
  # @example
  #   RequestMeter.configure do |config|
  #     config.api_key_header = "X-API-Key"
  #     config.quota_limit = 1000
  #   end
  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end
end
