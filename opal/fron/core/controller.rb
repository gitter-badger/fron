module Fron
  class Controller
    class << self
      attr_accessor :baseComponent, :routes, :beforeFilters, :events

      def base(component)
        @baseComponent = component
      end

      def route(*args)
        @routes ||= []
        @routes << Router.map(*args)
      end

      def on(name,action)
        @events ||= []
        @events << {name: name, action: action}
      end

      def beforeFilter(method,actions)
        @beforeFilters ||= []
        @beforeFilters << {method: method, actions: actions}
      end
    end

    attr_reader :base

    def initialize
      if self.class.baseComponent
        @base = self.class.baseComponent.new
      else
        @base = DOM::Element.new 'div'
      end

      return unless self.class.events
      self.class.events.each do |event|
        Eventable.on event[:name] do self.send(event[:action]) end
      end
    end
  end
end
