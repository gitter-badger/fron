require 'fron/core/behaviors/components'
require 'fron/core/behaviors/events'
require 'fron/core/behaviors/routes'

module Fron
  # Component
  class Component < DOM::Element
    attr_reader :model

    class << self
      attr_reader :tagname
      attr_reader :behaviors

      # Register a behavior
      #
      # @param behavior [Module] The behavior
      # @param methods [Array] The methods to register
      def register(behavior, methods)
        @behaviors ||= {}
        @behaviors[behavior] = methods

        methods.each do |name|
          instance_variable_set "@#{name}", []
          metaDef name do |*args, &block|
            args << block if block_given?
            instance_variable_get("@#{name}") << args
          end
        end
      end

      # Handles inheritance
      #
      # @param subclass [Class] The subclass
      def inherited(subclass)
        # Copy behaviours
        subclass.instance_variable_set '@behaviors', @behaviors.dup

        # Copy registries
        @behaviors.values.reduce(&:+).each do |type|
          next unless (var = instance_variable_get("@#{type}"))
          instVar = subclass.instance_variable_get("@#{type}") || []
          subclass.instance_variable_set("@#{type}", instVar.concat(var))
        end
      end

      # Sets the tag name of the component
      #
      # @param tag [String] The tag name
      def tag(tag)
        @tagname = tag
      end
    end

    include Behaviors::Components
    include Behaviors::Events

    # Initalizs the component
    #
    # @param tag [String] The tagname
    def initialize(tag = nil)
      klass = self.class

      super tag || klass.tagname || klass.name.split('::').last

      klass.behaviors.each do |mod, methods|
        methods.each do |name|
          next unless mod.respond_to?(name)
          registry = self.class.instance_variable_get("@#{name}")
          instance_exec registry, &mod.method(name)
        end
      end
    end
  end
end
