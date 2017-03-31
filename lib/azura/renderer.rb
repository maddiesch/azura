require 'active_support/concern'

module Azura
  module Renderer
    extend ActiveSupport::Concern

    def render_resources(objects, truncated: false)
      array = objects.map { |o| object_hash(o, truncated) }
      render json: { data: array }
    end

    def render_resource(object, truncated: false)
      render json: { data: object_hash(object, truncated) }
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
