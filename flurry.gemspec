# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'flurry/version'

Gem::Specification.new do |spec|
  spec.name          = 'flurry'
  spec.version       = Flurry::VERSION
  spec.homepage      = 'https://github.com/rbague/flurry'
  spec.license       = 'MIT'
  spec.summary       = 'A wrapper around Flurry Analytics Reporting API'
  spec.description   = <<-DESCRIPTION
  Flurry provides easy access to Flurry Analytics Reporting API
  with a friendly API.
  DESCRIPTION

  spec.authors       = ['Roger Bagué']
  spec.email         = ['rogerbague@gmail.com']

  spec.files         = Dir['{lib}/**/*.rb', 'LICENSE']
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'httparty', '~> 0.13.7'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
