# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'faraday_middleware/octokit/prometheus/version'

Gem::Specification.new do |spec|
  spec.name          = "faraday_middleware-octokit-prometheus"
  spec.version       = FaradayMiddleware::Octokit::Prometheus::VERSION
  spec.authors       = ["Masahiro Sano"]
  spec.email         = ["sabottenda@gmail.com"]

  spec.summary       = %q{faraday middleware for octokit to collect metrics for Prometheus.}
  spec.description   = %q{faraday middleware for octokit to collect metrics for Prometheus.}
  spec.homepage      = "https://github.com/kazegusuri/faraday_middleware-octokit-prometheus"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "octokit"
  spec.add_dependency "prometheus-client"
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
