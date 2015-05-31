require 'octokit'
require 'prometheus/client'

module FaradayMiddleware::Octokit::Prometheus
  class Collector < Faraday::Response::Middleware
    OCTOKIT_FILE = Regexp.new(%r{/lib/octokit/client/})
    BASE_METHOD = %w(request get put post patch delete head paginate)

    def initialize(env = nil)
      super
      @request = ::Prometheus::Client.registry.counter(
        :github_request_total,
        'A counter of the total number of GitHub API requests.')
      @request_duration = ::Prometheus::Client.registry.counter(
        :github_request_durations_total_microseconds,
        'The total amount of time spent requesting GitHub (microseconds).')
    end

    def call(env)
      started_at = Time.now.to_f
      @app.call(env).on_complete do |environment|
        duration = (Time.now.to_f - started_at) * 1000000
        environment[:duration] = duration.to_i
        on_complete(environment)
      end
    end

    def on_complete(env)
      location = caller_locations(1, 20).select{ |loc|
        OCTOKIT_FILE.match(loc.path)
      }.find{ |loc|
        !BASE_METHOD.include?(loc.label)
      }
      op = location.nil? ? "unknown" : location.label
      labels = FaradayMiddleware::Octokit::Prometheus.labels || {}
      labels = labels.merge(
        op: op,
        status: env[:status],
      )
      @request.increment(labels)
      @request_duration.increment(labels, env[:duration])
    end

    ::Faraday::Response.register_middleware :octokit_prometheus_collector => self
  end
end
