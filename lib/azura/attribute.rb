module Azura
  class Attribute
    attr_reader :name, :getter, :type, :truncated

    def initialize(name:, getter:, type:, truncated:)
      raise ArgumentError, 'Expected type to be a `Azura::Type`' unless type.is_a?(Azura::Type)
      @name      = name
      @getter    = getter
      @type      = type
      @truncated = truncated
    end

    def fetch(object)
      object.model.send(getter)
    end

    def truncated?
      truncated
    end
  end
end
