module Resque
  module UniqueByArity
    module Validation
      def self.included(base)
        unless base.uniq_config.skip_arity_validation?
          um = base.method(:perform)
          base.uniq_config.validate_arity(base.to_s, um)
        end
      end
    end
  end
end
