module Azura
  module Errors
    class BaseError < StandardError; end

    class MissingTypeError < BaseError; end
    class TypeMismatchError < BaseError; end
    class UnpermittedAttributeError < BaseError; end
    class IDMismatchError < BaseError; end
  end
end
