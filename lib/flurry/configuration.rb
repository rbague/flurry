module Flurry
  # Contains all the configuration for the gem
  class Configuration
    attr_accessor :token, :time_zone

    def initialize
      @token = nil
      @time_zone = nil
    end
  end
end
