module Azura
  class Type
    class Boolean; end

    MAPPINGS = {
      primary_key: Integer,
      string: String,
      text: String,
      integer: Integer,
      float: Float,
      decimal: Float,
      datetime: DateTime,
      time: Time,
      date: Date,
      binary: Data,
      boolean: Azura::Type::Boolean
    }.freeze

    DATE_FORMAT = '%Y-%m-%d'.freeze
    DATETIME_FORMAT = '%Y-%m-%dT%H:%M:%SZ'.freeze

    attr_reader :klass

    class << self
      def create_type(model, name)
        column = model.columns.detect { |c| c.name == name.to_s }
        raise "Column not found #{model.name}##{name}" if column.nil?
        klass = MAPPINGS[column.type]
        raise "Unsupported type #{type}" if klass.nil?
        new(klass)
      end
    end

    def initialize(klass)
      @klass = klass
    end

    def format_value(value)
      case value
      when String
        value.presence
      when Time, DateTime
        value.utc.strftime(DATETIME_FORMAT)
      when Date
        value.utc.strftime(DATE_FORMAT)
      else
        value
      end
    end
  end
end
