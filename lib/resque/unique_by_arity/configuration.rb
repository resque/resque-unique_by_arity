require 'logger'
module Resque
  module UniqueByArity
    class Configuration
      VALID_ARITY_VALIDATION_LEVELS = [ :warning, :error, :skip, nil, false ]
      SKIPPED_ARITY_VALIDATION_LEVELS = [ :skip, nil, false ]
      attr_accessor :logger
      attr_accessor :log_level
      attr_accessor :arity_for_uniqueness
      attr_accessor :arity_validation
      attr_accessor :lock_after_execution_period
      attr_accessor :runtime_lock_timeout
      attr_accessor :unique_at_runtime
      attr_accessor :unique_in_queue
      attr_accessor :unique_across_queues
      def initialize(**options)
        @logger = options.key?(:logger) ? options[:logger] : Logger.new(STDOUT)
        @log_level = options.key?(:log_level) ? options[:log_level] : :debug
        @arity_for_uniqueness = options.key?(:arity_for_uniqueness) ? options[:arity_for_uniqueness] : 1
        @arity_validation = options.key?(:arity_validation) ? options[:arity_validation] : :warning
        raise ArgumentError, "UniqueByArity::Cop.new requires arity_validation values of #{arity_validation.inspect}, or a class inheriting from Exception, but the value is #{@arity_validation} (#{@arity_validation.class})" unless VALID_ARITY_VALIDATION_LEVELS.include?(@arity_validation) || !@arity_validation.respond_to?(:ancestors) || @arity_validation.ancestors.include?(Exception)
        @lock_after_execution_period = options.key?(:lock_after_execution_period) ? options[:lock_after_execution_period] : nil
        @runtime_lock_timeout = options.key?(:runtime_lock_timeout) ? options[:runtime_lock_timeout] : nil
        @unique_at_runtime = options.key?(:unique_at_runtime) ? options[:unique_at_runtime] : false
        @unique_in_queue = options.key?(:unique_in_queue) ? options[:unique_in_queue] : false
        @unique_across_queues = options.key?(:unique_across_queues) ? options[:unique_across_queues] : false
        # The default config initialization shouldn't trigger any warnings.
        if options.keys.length > 0 && @logger
          log ":arity_for_uniqueness is set to #{@arity_for_uniqueness}, but no uniqueness enforcement was turned on [:unique_at_runtime, :unique_in_queue, :unique_across_queues]" unless @unique_at_runtime || @unique_in_queue || @unique_across_queues
          log ":lock_after_execution_period is set to #{@lock_after_execution_period}, but :unique_at_runtime is not set" if @lock_after_execution_period && !@unique_at_runtime
          log ":unique_in_queue and :unique_across_queues should not be set at the same time, as :unique_across_queues will always supercede :unique_in_queue" if @unique_in_queue && @unique_across_queues
        end
      end

      def unique_logger
        logger
      end

      def unique_log_level
        log_level
      end

      def log(msg)
        Resque::UniqueByArity.unique_log(msg, self)
      end
      
      def to_hash
        {
            logger: logger,
            log_level: log_level,
            arity_for_uniqueness: arity_for_uniqueness,
            arity_validation: arity_validation,
            lock_after_execution_period: lock_after_execution_period,
            runtime_lock_timeout: runtime_lock_timeout,
            unique_at_runtime: unique_at_runtime,
            unique_in_queue: unique_in_queue,
            unique_across_queues: unique_across_queues
        }
      end

      def skip_arity_validation?
        SKIPPED_ARITY_VALIDATION_LEVELS.include?(arity_validation)
      end

      def validate_arity(klass_string, perform_method)
        return true if skip_arity_validation?
        # method.arity -
        #   Returns an indication of the number of arguments accepted by a method.
        #   Returns a non-negative integer for methods that take a fixed number of arguments.
        #   For Ruby methods that take a variable number of arguments, returns -n-1, where n is the number of required arguments.
        #   For methods written in C, returns -1 if the call takes a variable number of arguments.
        # Example:
        #   for perform(opts = {}), method(:perform).arity # => -1
        #   which means that the only valid arity_for_uniqueness is 0
        msg = if perform_method.arity >= 0
                # takes a fixed number of arguments
                # parform(a, b, c) # => arity == 3, so arity for uniqueness can be 0, 1, 2, or 3
                if perform_method.arity < arity_for_uniqueness
                  "#{klass_string}.#{perform_method.name} has arity of #{perform_method.arity} which will not work with arity_for_uniqueness of #{arity_for_uniqueness}"
                end
              else
                if (perform_method.arity).abs < arity_for_uniqueness
                  # parform(a, b, c, opts = {}) # => arity == -4
                  #   and in this case arity for uniqueness can be 0, 1, 2, or 3, because 4 of the arguments are required
                  "#{klass_string}.#{perform_method.name} has arity of #{perform_method.arity} which will not work with arity_for_uniqueness of #{arity_for_uniqueness}"
                elsif (required_parameter_names = perform_method.parameters.take_while { |a| a[0] == :req }.map { |b| b[1] }).length < arity_for_uniqueness
                  "#{klass_string}.#{perform_method.name} has the following required parameters: #{required_parameter_names}, which is not enough to satisfy the configured arity_for_uniqueness of #{arity_for_uniqueness}"
                end
              end
        case arity_validation
          when :warning then
            log(ColorizedString[msg].red)
          when :error then
            raise ArgumentError, msg
          else
            raise arity_validation, msg
        end if msg
      end
    end
  end
end
