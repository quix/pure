
module Pure
  module PurePrivate
    module Error
      class BaseError < StandardError
      end
      
      class ParseError < BaseError
      end
    end
  end
end
