module LightService
  module Action

    def self.included(base_class)
      base_class.extend Macros
    end

    module Macros
      def executed
        eigenclass = class << self; self end
        eigenclass.send(:define_method, :execute, lambda do |context|
          return context if context.failure?
          yield(context)
          context
        end)
      end
    end

  end
end
