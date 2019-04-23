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

    def merge(hsh, other)
      (hsh || {}).merge(other || {}) do |_key, old_val, new_val|
        if old_val.is_a?(Hash)
          merge old_val, new_val
        elsif old_val.is_a?(Array)
          old_val | new_val
        elsif old_val.is_a?(String)
          old_val << new_val
        else
          new_val
        end
      end
    end
  end
end
