module Resque
  module UniqueByArity
    module Validation
      def self.included(base)
        @um = base.method(:perform)
        base.uniq_config.validate_arity(base.to_s, @um) if base.uniq_config.arity_validation
      end
    end
  end
end

