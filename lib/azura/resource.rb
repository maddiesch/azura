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

      def attribute(name, getter: nil, type: nil, truncated: true, assignable_on: [], rendered: true)
        r_getter = getter || name
        r_type = type || Azura::Type.create_type(model, r_getter)
        attr = Azura::Attribute.new(name: name, getter: r_getter, type: r_type, truncated: truncated, assignable_on: assignable_on, rendered: rendered)
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

    # Update / Create
    def update(params)
      attributes = assignable_attributes(:update)
      data = extract_data(params, true)
      assign_values(data, attributes)
      model
    end

    def create(params)
      attributes = assignable_attributes(:create)
      data = extract_data(params, false)
      assign_values(data, attributes)
      model
    end

    private

    def assign_values(data, attributes)
      data[:attributes].each do |name, value|
        attr = attributes.detect { |a| a.name.to_s == name.to_s }
        raise Azura::Errors::UnpermittedAttributeError, "Can't assign #{name}" if attr.nil?
        attr.assign(self, value)
      end
    end

    def extract_data(params, validate_id)
      raw_attrs = params.require(:data).permit!.to_h
      raise Azura::Errors::MissingTypeError unless (type = raw_attrs[:type]).present?
      raise Azura::Errors::TypeMismatchError unless type == self.class.type
      if validate_id
        raise Azura::Errors::IDMismatchError unless raw_attrs[:id] == id
      elsif raw_attrs[:id].present?
        raise Azura::Errors::UnpermittedAttributeError, "Can't assign ID"
      end
      raw_attrs
    end

    def assignable_attributes(method)
      self.class.attributes.select { |a| a.assignable_on.include?(method) }
    end

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
