# FaradayMiddleware::Octokit::Prometheus

Faraday middleware for octokit to collect metrics for [Prometheus](http://prometheus.io/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'faraday_middleware-octokit-prometheus'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install faraday_middleware-octokit-prometheus

## Metrics

Current collecting metrics:

- `github_request_total`: The total number of GitHub API requests per label
- `github_request_durations_total_microseconds`: The total amount of time spent requesting GitHub (microseconds) per label.

Default labels:

- `op`: GitHub API name which corresponds with Octokit method name
- `status`: response status

## Usage

Just specify Ocotkit to use this faraday middleware by either:

```
require 'faraday_middleware/octokit/prometheus'
stack = Faraday::RackBuilder.new do |builder|
  builder.response :logger
  builder.response :octokit_prometheus_collector
  builder.use Octokit::Response::RaiseError
  builder.adapter Faraday.default_adapter
end
Octokit.middleware = stack
```

Or by using `Octokit.middleware.use`:

```
require 'faraday_middleware/octokit/prometheus'
Octokit.middleware.use FaradayMiddleware::Octokit::Prometheus::Collector
```

After the setup, you can use Octokit methods as usual and the middleware collects metrics for Prometheus.


### Additional Labels

You can specify additional labels for each metrics.

```
FaradayMiddleware::Octokit::Prometheus.labels = {
  hostname: `hostname`.chomp,
  pid: Process.uid,
}
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kazegusuri/faraday_middleware-octokit-prometheus. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

