require 'logger'
module Resque
  module UniqueByArity
    class Configuration
      VALID_ARITY_VALIDATION_LEVELS = [:warning, :error, :skip, nil, false].freeze
      SKIPPED_ARITY_VALIDATION_LEVELS = [:skip, nil, false].freeze
      DEFAULT_AT_RUNTIME_KEY_BASE = 'r-uar'.freeze
      DEFAULT_IN_QUEUE_KEY_BASE = 'r-uiq'.freeze
      attr_accessor :logger
      attr_accessor :log_level
      attr_accessor :arity_for_uniqueness
      attr_accessor :arity_validation
      attr_accessor :lock_after_execution_period
      attr_accessor :runtime_lock_timeout
      attr_accessor :runtime_requeue_interval
      attr_accessor :unique_at_runtime
      attr_accessor :unique_at_runtime_key_base
      attr_accessor :unique_in_queue
      attr_accessor :unique_in_queue_key_base
      attr_accessor :unique_across_queues
      attr_accessor :base_klass_name
      attr_accessor :debug_mode
      def initialize(**options)
        @logger = options.key?(:logger) ? options[:logger] : Logger.new(STDOUT)
        @log_level = options.key?(:log_level) ? options[:log_level] : :debug
        @arity_for_uniqueness = options.key?(:arity_for_uniqueness) ? options[:arity_for_uniqueness] : 1
        @arity_validation = options.key?(:arity_validation) ? options[:arity_validation] : :warning
        raise ArgumentError, "Resque::Plugins::UniqueByArity.new requires arity_validation values of #{arity_validation.inspect}, or a class inheriting from Exception, but the value is #{@arity_validation} (#{@arity_validation.class})" unless VALID_ARITY_VALIDATION_LEVELS.include?(@arity_validation) || !@arity_validation.respond_to?(:ancestors) || @arity_validation.ancestors.include?(Exception)

        @lock_after_execution_period = options.key?(:lock_after_execution_period) ? options[:lock_after_execution_period] : nil
        @runtime_lock_timeout = options.key?(:runtime_lock_timeout) ? options[:runtime_lock_timeout] : nil
        @runtime_requeue_interval = options.key?(:runtime_requeue_interval) ? options[:runtime_requeue_interval] : nil
        @unique_at_runtime = options.key?(:unique_at_runtime) ? options[:unique_at_runtime] : false
        @unique_at_runtime_key_base = options.key?(:unique_at_runtime_key_base) ? options[:unique_at_runtime_key_base] : DEFAULT_AT_RUNTIME_KEY_BASE
        @unique_in_queue_key_base = options.key?(:unique_in_queue_key_base) ? options[:unique_in_queue_key_base] : DEFAULT_IN_QUEUE_KEY_BASE
        @unique_in_queue = options.key?(:unique_in_queue) ? options[:unique_in_queue] : false
        @unique_across_queues = options.key?(:unique_across_queues) ? options[:unique_across_queues] : false
        # Can't be both unique in queue and unique across queues.
        raise ArgumentError, "Resque::Plugins::UniqueByArity.new requires either one or none of @unique_across_queues and @unique_in_queue to be true. Having both set to true is non-sensical." if @unique_in_queue && @unique_across_queues
        env_debug = ENV['RESQUE_DEBUG']
        @debug_mode = !!(options.key?(:debug_mode) ? options[:debug_mode] : env_debug == 'true' || (env_debug.is_a?(String) && env_debug.match?(/arity/)))
      end

      def validate
        # The default config initialization shouldn't trigger any warnings.
        if base_klass_name && logger
          log "[#{base_klass_name}] :arity_for_uniqueness is set to #{arity_for_uniqueness}, but no uniqueness enforcement was turned on [:unique_at_runtime, :unique_in_queue, :unique_across_queues]" unless unique_at_runtime || unique_in_queue || unique_across_queues
          log "[#{base_klass_name}] :lock_after_execution_period is set to #{lock_after_execution_period}, but :unique_at_runtime is not set" if lock_after_execution_period && !(unique_in_queue || unique_across_queues)
          log "[#{base_klass_name}] :runtime_lock_timeout is set to #{runtime_lock_timeout}, but :unique_at_runtime is not set" if runtime_lock_timeout && !unique_at_runtime
          log "[#{base_klass_name}] :runtime_requeue_interval is set to #{runtime_requeue_interval}, but :unique_at_runtime is not set" if runtime_requeue_interval && !unique_at_runtime
          log "[#{base_klass_name}] :unique_in_queue and :unique_across_queues should not be set at the same time, as :unique_across_queues will always supercede :unique_in_queue" if unique_in_queue && unique_across_queues
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
          log_level: log_level,
          logger: logger,
          arity_for_uniqueness: arity_for_uniqueness,
          arity_validation: arity_validation,
          base_klass_name: base_klass_name,
          debug_mode: debug_mode,
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
                if perform_method.arity.abs < arity_for_uniqueness
                  # parform(a, b, c, opts = {}) # => arity == -4
                  #   and in this case arity for uniqueness can be 0, 1, 2, or 3, because 4 of the arguments are required
                  "#{klass_string}.#{perform_method.name} has arity of #{perform_method.arity} which will not work with arity_for_uniqueness of #{arity_for_uniqueness}"
                elsif (required_parameter_names = perform_method.parameters.take_while { |a| a[0] == :req }.map { |b| b[1] }).length < arity_for_uniqueness
                  "#{klass_string}.#{perform_method.name} has the following required parameters: #{required_parameter_names}, which is not enough to satisfy the configured arity_for_uniqueness of #{arity_for_uniqueness}"
                end
              end
        if msg
          case arity_validation
          when :warning then
            log(ColorizedString[msg].red)
          when :error then
            raise ArgumentError, msg
          else
            raise arity_validation, msg
          end
        end
      end
    end
  end
end
