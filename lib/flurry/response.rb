module Flurry
  class Response # :nodoc:
    def initialize(response)
      @response = response
    end

    def body
      @response.parsed_response
    end

    def code
      @response.code
    end

    def message
      raw.message
    end

    def raw
      @response.response
    end
  end
end
