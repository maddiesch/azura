module Azura
  class Formatter
    class << self
      def format(resource:, truncated:)
        case resource
        when Array
          resource.map { |r| format(resource: r, truncated: truncated) }
        when Azura::Resource
          object_hash(resource, truncated)
        else
          raise 'Unknown Type for resource'
        end
      end

      private

      def object_hash(object, truncated)
        {}.tap do |root|
          root[:id]   = object.id
          root[:type] = object.class.type
          root[:attributes] = {}.tap do |attrs|
            object.class.attributes.sort_by(&:name).each do |attr|
              next unless attr.rendered?
              next if truncated && !attr.truncated?
              value = attr.fetch(object)
              attrs[attr.name] = attr.type.format_value(value)
            end
          end
          root[:relationships] = {}.tap do |rel|
            object.class.relationships.sort_by(&:name).each do |r|
              rel[r.name] = object_relationship(r, object)
            end
          end
        end
      end

      def object_relationship(relationship, object)
        id = object.model.send(relationship.getter)
        if relationship.to_many
          if Array(id).any?
            { data: Array(id).map { |i| { id: i.to_s, type: relationship.type } } }
          else
            { data: [] }
          end
        elsif id.nil?
          { data: nil }
        else
          { data: { id: id.to_s, type: relationship.type } }
        end
      end
    end
  end
end
