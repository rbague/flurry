module Flurry
  # Contains all the configuration for the gem
  class Configuration
    attr_accessor :token, :time_zone, :format, :timeout

    def initialize
      @token = nil
      @time_zone = nil
      @format = nil
      @timeout = nil
    end
  end
end
