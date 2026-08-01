# frozen_string_literal: true

module Resque
  module UniqueByArity
    # Version namespace for this gem.
    module Version
      # Current gem version.
      VERSION = "3.0.3"
    end
    # Current gem version exposed at the traditional constant location.
    VERSION = Version::VERSION # Traditional Constant Location
  end
end
