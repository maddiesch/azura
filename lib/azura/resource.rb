require 'active_support/inflector'

module Azura
  class Resource
    class << self
      # The model class that backs this resource
      def model(model = nil)
        @model = model if model
        @model
      end

      # The type name for the resource.  Default: Model name
      def type(type = nil)
        @type = type if type
        @type || name.split('::').last.gsub(/Resource$/, '').underscore
      end

      # Add an attribute
      def add_attribute(attr)
        raise ArgumentError, 'expected attribute to be a `Azura::Attribute`' unless attr.is_a?(Azura::Attribute)
        attributes << attr
      end

      def attribute(name, getter: nil, type: nil, truncated: true)
        r_getter = getter || name
        r_type = type || Azura::Type.create_type(model, r_getter)
        attr = Azura::Attribute.new(name: name, getter: r_getter, type: r_type, truncated: truncated)
        add_attribute(attr)
      end

      def relationship(name, type, getter: nil, to_many: false)
        r_getter = getter || "#{name}_id"
        rel = Azura::Relationship.new(name: name, type: type, getter: r_getter, to_many: to_many)
        relationships << rel
      end

      # All the attributes in the resource
      def attributes
        @attributes ||= []
        @attributes
      end

      def relationships
        @relationships ||= []
        @relationships
      end
    end

    attr_reader :model

    # Create a new resource with the passed model.
    # Will raise `ArgumentError` if the passed model isn't an instance of the model class
    def initialize(model:)
      raise ArgumentError, 'Unexpected type' unless model.is_a?(self.class.model)
      @model = model
    end

    # Get the ID for the resource
    def id
      model.id.to_s
    end

    # Generate the JSON representation for this resource
    def as_json
      {}.tap do |root|
        root[:id] = id
        root[:type] = self.class.type
        root[:attributes] = generate_attributes
        root[:relationships] = generate_relationships
        root[:meta] = generate_metadata
      end
    end

    private

    def generate_attributes
      {}.tap do |attrs|
        self.class.attributes.sort_by(&:name).each do |attr|
          attrs[attr.name] = fetch_attribute(attr)
        end
      end
    end

    def generate_relationships
      {}
    end

    def generate_metadata
      {}
    end

    def fetch_attribute(attr)
      value = if respond_to?(attr.getter)
                send(attr.getter)
              else
                model.send(attr.getter)
              end
      attr.type.format_value(value)
    end
  end
end
