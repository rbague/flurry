require 'bundler/setup'
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
end
