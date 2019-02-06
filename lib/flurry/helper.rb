require 'date'

module Flurry
  # Helper methods used across the library
  module Helper
    private

    def camelize(string)
      string = string.sub(/^(?:(?=\b|[A-Z_])|\w)/) { $&.downcase }
      string.gsub(%r{(?:_|(/))([a-z\d]*)}) do
        "#{Regexp.last_match(1)}#{Regexp.last_match(2).capitalize}"
      end.gsub('/', '::')
    end

    def datetime?(value)
      value.respond_to?(:strftime)
    end

    def tomorrow(date)
      tomorrow = Date.parse(date.to_s) if date.is_a?(Time)
      (tomorrow || date) + 1
    end
  end
end
