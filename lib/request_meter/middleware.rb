# frozen_string_literal: true

require "rack/request"

module RequestMeter
  class Middleware
    def initialize(app)
      @app = app
      @cache_client = RequestMeter.configuration.cache_client

      return unless @cache_client.nil?

      raise MissingCacheClientError, "Cache client is required"
    end

    def call(env)
      req = Rack::Request.new(env)
      api_key = req.get_header("HTTP_#{RequestMeter.configuration.api_key_header.upcase.gsub("-", "_")}")

      if api_key.nil? || api_key.empty?
        return [400, { "Content-Type" => "application/json" }, [{ error: "API key is required" }.to_json]]
      end

      quota_limit = RequestMeter.configuration.get_quota_limit(api_key)
      quota_period = RequestMeter.configuration.get_quota_period_seconds(api_key)

      if quota_limit.nil? || quota_period.nil?
        return [400, { "Content-Type" => "application/json" },
                [{ error: "Limits are not configured for the provided token" }.to_json]]
      end

      cache_key = "request_meter:#{api_key}"

      current_count = @cache_client.incr(cache_key)

      @cache_client.expire(cache_key, quota_period) if current_count == 1

      if current_count > quota_limit
        reset_in = @cache_client.ttl(cache_key)
        headers = { "Retry-After" => reset_in.to_s }
        return [429, headers, ["Quota exceeded. Try again in #{reset_in} seconds."]]
      end

      @app.call(env)
    end
  end
end
