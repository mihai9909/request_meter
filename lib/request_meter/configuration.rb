# frozen_string_literal: true

module RequestMeter
  class Configuration
    attr_accessor :quota_limit, :quota_period_seconds, :api_key_header, :cache_client

    def initialize
      @quota_limit = 1000
      @quota_period_seconds = 3600
      @api_key_header = "X-API-Key"
      @cache_client = nil
    end

    def get_quota_limit(api_key)
      if @quota_limit.is_a?(Proc)
        @quota_limit.call(api_key)
      else
        @quota_limit
      end
    end

    def get_quota_period_seconds(api_key)
      if @quota_period_seconds.is_a?(Proc)
        @quota_period_seconds.call(api_key)
      else
        @quota_period_seconds
      end
    end
  end
end
