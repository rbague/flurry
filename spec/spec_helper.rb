require 'bundler/setup'
require 'webmock/rspec'
require 'flurry'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
    c.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.before(:all) do
    Flurry.configure do |c|
      c.token = ENV['FLURRY_TOKEN']
    end
  end

  config.before(:each, http: true) do
    stub_request(:get, /api-metrics.flurry.com/)
      .to_return(lambda do |request|
        format = request.uri.query_values['format']
        format = 'json' if format.nil? || format.empty?
        File.new(File.join(__dir__, 'stubs', "response.#{format}"))
      end)
  end
end
