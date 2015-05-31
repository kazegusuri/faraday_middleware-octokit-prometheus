require 'spec_helper'
require 'faraday'

describe FaradayMiddleware::Octokit::Prometheus::Collector do
  before :each do
    stack = Faraday::RackBuilder.new do |builder|
      builder.request(:url_encoded)
      builder.response(:octokit_prometheus_collector)
      builder.adapter(:test) do |stub|
        stub.get("/users/kazegusuri") {
          [200, {"Content-Type" => "text/plain"}, "kazegusuri"]
        }
        stub.get("/users/unknown") {
          [404, {"Content-Type" => "text/plain"}, "unknown"]
        }
        stub.get("/users/long_time") {
          sleep 1
          [200, {"Content-Type" => "text/plain"}, "long_time"]
        }
      end
    end
    Octokit.middleware = stack
    Prometheus::Client.registry.instance_variable_set(:@metrics, {})
    FaradayMiddleware::Octokit::Prometheus.labels = nil
  end

  let(:request) { ::Prometheus::Client.registry.get(:github_request_total) }
  let(:request_duration) { ::Prometheus::Client.registry.get(:github_request_durations_total_microseconds) }

  describe 'via octokit' do
    it 'collects request counts and durations' do
      3.times do
        Octokit.user 'kazegusuri'
      end

      expect(request.values.size).to eq(1)

      key, value = request.values.first
      expect(key).to match({
        op: 'user',
        status: 200,
      })
      expect(value).to eq(3)

      key, duration = request_duration.values.first
      expect(key).to match({
        op: 'user',
        status: 200,
      })
      expect(duration).to be < 10000
    end

    it 'collects status as label' do
      Octokit.user 'kazegusuri'
      Octokit.user 'unknown'

      expect(request.values.size).to eq(2)
      _, value = request.values.find { |key, _| key[:op] == 'user' && key[:status] == 200 }
      expect(value).to eq(1)
      _, value = request.values.find { |key, _| key[:op] == 'user' && key[:status] == 404 }
      expect(value).to eq(1)
    end

    it 'measures duration' do
      Octokit.user 'long_time'
      expect(request_duration.values.size).to eq(1)
      _, duration = request_duration.values.first
      expect(duration).to be > 1000000
    end

    it 'can specify additional labels' do
      FaradayMiddleware::Octokit::Prometheus.labels = {foo: 'bar'}
      Octokit.user 'kazegusuri'

      expect(request.values.size).to eq(1)
      key, _ = request.values.first
      expect(key).to include(:foo)
    end
  end

  describe 'directly use middleware not via octokit' do
    let(:con) {
      Faraday.new(:url => "http://sushi.com") do |builder|
        builder.response(:octokit_prometheus_collector)
        builder.adapter(:test) do |stub|
          stub.get("/users/kazegusuri") {
            [200, {"Content-Type" => "text/plain"}, "kazegusuri"]
          }
        end
      end
    }

    it 'can collect metrics but op is unknown' do
      con.get('/users/kazegusuri')
      expect(request.values.size).to eq(1)

      key, value = request.values.first
      expect(key).to match({
        op: 'unknown',
        status: 200,
      })
      expect(value).to eq(1)

      key, duration = request_duration.values.first
      expect(key).to match({
        op: 'unknown',
        status: 200,
      })
      expect(duration).to be < 10000
    end
  end
end
