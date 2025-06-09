# frozen_string_literal: true

module RequestMeter
  # Configuration class holds settings for the RequestMeter middleware.
  #
  # It manages API request quota limits, time windows, header keys, and the cache client.
  #
  # @example Default configuration
  #   config = RequestMeter::Configuration.new
  #   config.quota_limit           #=> 1000
  #   config.quota_period_seconds  #=> 3600
  #   config.api_key_header        #=> "X-API-Key"
  #
  # @api public
  class Configuration
    # @return [Integer, Proc] maximum allowed requests per quota period or a Proc returning limit by api_key
    attr_accessor :quota_limit
    # @return [Integer, Proc] quota window length in seconds or a Proc returning period by api_key
    attr_accessor :quota_period_seconds
    # @return [String] HTTP header name that holds the API key
    attr_accessor :api_key_header
    # @return [Object, nil] Cache client (e.g. Redis) used for tracking requests
    attr_accessor :cache_client

    # Initializes a new Configuration with default values.
    #
    # Defaults:
    # - quota_limit: 1000
    # - quota_period_seconds: 3600 (1 hour)
    # - api_key_header: "X-API-Key"
    # - cache_client: nil
    #
    # @return [void]
    def initialize
      @quota_limit = 1000
      @quota_period_seconds = 3600
      @api_key_header = "X-API-Key"
      @cache_client = nil
    end

    # Returns the quota limit for a given API key.
    #
    # If quota_limit is a Proc, it is called with the api_key, otherwise returns the fixed limit.
    #
    # @param api_key [String] the API key to check
    # @return [Integer] the quota limit for that API key
    def get_quota_limit(api_key)
      if @quota_limit.is_a?(Proc)
        @quota_limit.call(api_key)
      else
        @quota_limit
      end
    end

    # Returns the quota period (in seconds) for a given API key.
    #
    # If quota_period_seconds is a Proc, it is called with the api_key, otherwise returns the fixed period.
    #
    # @param api_key [String] the API key to check
    # @return [Integer] the quota period in seconds for that API key
    def get_quota_period_seconds(api_key)
      if @quota_period_seconds.is_a?(Proc)
        @quota_period_seconds.call(api_key)
      else
        @quota_period_seconds
      end
    end
  end
end
