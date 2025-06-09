# frozen_string_literal: true

require_relative "request_meter/version"
require "request_meter/middleware"
require "request_meter/configuration"

module RequestMeter
  class MissingCacheClientError < StandardError; end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end
end
