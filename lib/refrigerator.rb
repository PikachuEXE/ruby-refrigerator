# frozen_string_literal: true

require File.join(File.dirname(__FILE__), "refrigerator/utils")

# Refrigerator allows for easily freezing core classes and modules.
module Refrigerator
  version_int = RUBY_VERSION[0..2].sub('.', '').to_i
  version_int = 24 if version_int > 24

  # @api private
  # Array of strings containing class or module names.
  CORE_MODULE_NAMES = File.read(File.expand_path(File.join(File.expand_path(__FILE__), "../../module_names/#{version_int}.txt"))).
    split(/\s+/).
    select{ |constant_name| Utils.constantize(constant_name) }.
    each(&:freeze).
    freeze
  # Use `private_constant` if supported (>= 2.0)
  if respond_to?(:private_constant)
    private_constant(:CORE_MODULE_NAMES)
  end

  # @api private
  # Default frozen options hash
  OPTS = {}.freeze
  # Use `private_constant` if supported (>= 2.0)
  if respond_to?(:private_constant)
    private_constant(:OPTS)
  end

  # Freeze core classes and modules.  Options:
  # :except :: Don't freeze any of the classes modules listed (array of strings)
  def self.freeze_core(opts=OPTS)
    (CORE_MODULE_NAMES - Array(opts[:except])).each do |constant_name|
      Utils.constantize(constant_name).freeze
    end

    nil
  end

  # Check that requiring a given file does not modify any core classes. Options:
  # :depends :: Require the given files before freezing the core (array of strings)
  # :modules :: Define the given modules in the Object namespace before freezing the core (array of module name symbols)
  # :classes :: Define the given classes in the Object namespace before freezing the core (array of either class name Symbols or
  #             array with class Name Symbol and Superclass name string)
  # :except :: Don't freeze any of the classes modules listed (array of strings)
  def self.check_require(file, opts=OPTS)
    require 'rubygems'
    Array(opts[:depends]).each{|f| require f}
    Array(opts[:modules]).each{|m| Object.const_set(m, Module.new)}
    Array(opts[:classes]).each do |class_name, *superclass_names|
      super_class =
        if superclass_names.empty?
          ::Object
        else
          Utils.constantize(superclass_names.first)
        end

      Object.const_set(
        class_name,
        Class.new(super_class)
      )
    end
    freeze_core(:except => %w'Gem Gem::Specification'+Array(opts[:exclude]))
    require file
  end

  freeze
end
