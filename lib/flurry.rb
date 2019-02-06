require 'flurry/version'
require 'flurry/configuration'
require 'flurry/request'

module Flurry
  class Error < StandardError; end

  class << self
    # Start a Flurry configuration block in an initializer.
    #
    # Used to provide the Flurry API access token
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end

  def self.from(table, group_by = nil)
    raise Flurry::Error, 'a valid token must be provided before any call' if configuration.token.nil?
    Request.new(table, group_by)
  end
end
