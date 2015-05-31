require 'faraday_middleware/octokit/prometheus/version'
require 'faraday_middleware/octokit/prometheus/collector'

module FaradayMiddleware
  module Octokit
    module Prometheus
      class << self
        attr_accessor :labels
      end
    end
  end
end
