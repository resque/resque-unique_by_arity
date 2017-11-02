module Resque
  module UniqueByArity
    module Validation
      def perform(*_)
        uniq_config.validate_arity(self.to_s, self.method(:perform).super_method) if uniq_config.arity_validation
        super
      end
    end
  end
end

