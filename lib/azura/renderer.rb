require 'active_support/concern'

module Azura
  module Renderer
    extend ActiveSupport::Concern

    def render_resources(objects, truncated: false)
      result = Azura::Formatter.format(resource: objects, truncated: truncated)
      render json: { data: result }
    end

    def render_resource(object, truncated: false)
      result = Azura::Formatter.format(resource: object, truncated: truncated)
      render json: { data: result }
    end
  end
end
