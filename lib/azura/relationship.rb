module Azura
  class Relationship
    attr_reader :name, :getter, :type, :to_many

    def initialize(name:, type:, getter:, to_many:)
      @name = name
      @type = type
      @getter = getter
      @to_many = to_many
    end
  end
end
