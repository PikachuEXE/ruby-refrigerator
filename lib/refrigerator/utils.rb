# frozen_string_literal: true

module Refrigerator
  # @api private
  module Utils
    # Takes a constant name (and raise error if name invalid)
    # Returns constant value or `nil` if constant not found
    #
    # Modified from
    # http://apidock.com/rails/ActiveSupport/Inflector/safe_constantize
    def self.constantize(constant_name)
      # Special case for `ARGF.class`
      return ARGF.class if constant_name == "ARGF.class".freeze

      # Note that we allow lowercase as beginning to allow names like
      # `IO::generic_readable`
      match_data = /\A(?:::)?([A-Z]\w*(?:::[a-zA-Z]\w*)*)\z/.match(constant_name)
      unless match_data
        raise NameError, "#{constant_name.inspect} is not a valid constant name!"
      end

      Object.module_eval("::#{match_data[1]}", __FILE__, __LINE__)
    end
  end
  # Use `private_constant` if supported (>= 2.0)
  if respond_to?(:private_constant)
    private_constant(:Utils)
  end
end
