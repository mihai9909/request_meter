# RequestMeter


RequestMeter is a Rack middleware gem for Rails applications that limits API requests per API key within a specified timeframe.

It is ideal for Rails APIs wanting built-in request limits.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add request_meter
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install request_meter
```

## Setup

Add this line to `config/application.rb`

```
Rails.application.config.middleware.use RequestMeter::Middleware
```

Example `RequestMeter` configuration in `config/initializers/request_meter.rb`:

```
RequestMeter.configure do |config|
  config.api_key_header = "X-API-Key"
  config.cache_client = Rails.application.config.redis
  config.quota_limit = -> (api_key) {
    user = User.find_by(api_key: api_key)
    user&.quota_limit
  }
  config.quota_period_seconds = -> (api_key) {
    user = User.find_by(api_key: api_key)
    user&.quota_period_seconds
  }
end
```


- `api_key_header` used to get the API key from the request headers
    - default: `X-API-Key`

- `quota_limit` maximum number of requests that can be performed in the timeframe `quota_period_seconds` by an API key.
    - default: `1000`
    - type: `Proc` or `Integer`

- `quota_period_seconds` number of seconds in a timeframe
    - default: `3600`
    - type: `Proc` or `Integer`

- `cache_client` Client used to track request counts. **Note: Only has support for Redis**

The default configuration defines a global limit of `1000 requests per hour`

For custom behavior (e.g., per-user limits), use a `Proc` to dynamically determine values.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports, pull requests and ideas for improvement are welcome on GitHub at https://github.com/mihai9909/request_meter.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
