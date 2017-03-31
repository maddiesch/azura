module Azura
  class Attribute
    attr_reader :name, :getter, :type, :truncated, :assignable_on, :rendered

    def initialize(name:, getter:, type:, truncated:, assignable_on:, rendered:)
      raise ArgumentError, 'Expected type to be a `Azura::Type`' unless type.is_a?(Azura::Type)
      @name      = name
      @getter    = getter
      @type      = type
      @truncated = truncated
      @rendered  = rendered
      @assignable_on = assignable_on
    end

    def fetch(object)
      object.model.send(getter)
    end

    def assign(object, value)
      object.model.send("#{getter}=", value)
    end

    def truncated?
      truncated
    end

    def rendered?
      rendered
    end
  end
end
