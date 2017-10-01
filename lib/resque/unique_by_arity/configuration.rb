require 'logger'
module Resque
  module UniqueByArity
    class Configuration
      attr_accessor :logger
      attr_accessor :log_level
      attr_accessor :arity_for_uniqueness
      attr_accessor :lock_after_execution_period
      attr_accessor :unique_at_runtime
      attr_accessor :unique_in_queue
      attr_accessor :unique_across_queues
      def initialize(**options)
        @logger = options.key?(:logger) ? options[:logger] : Logger.new(STDOUT)
        @log_level = options.key?(:log_level) ? options[:log_level] : :debug
        @arity_for_uniqueness = options.key?(:arity_for_uniqueness) ? options[:arity_for_uniqueness] : 1
        @lock_after_execution_period = options.key?(:lock_after_execution_period) ? options[:lock_after_execution_period] : nil
        @unique_at_runtime = options.key?(:unique_at_runtime) ? options[:unique_at_runtime] : false
        @unique_in_queue = options.key?(:unique_in_queue) ? options[:unique_in_queue] : false
        @unique_across_queues = options.key?(:unique_across_queues) ? options[:unique_across_queues] : false
        # The default config initialization shouldn't trigger any warnings.
        if options.keys.length > 0
          warn ":arity_for_uniqueness is set to #{@arity_for_uniqueness}, but no uniqueness enforcement was turned on [:unique_at_runtime, :unique_in_queue, :unique_across_queues]" unless @unique_at_runtime || @unique_in_queue || @unique_across_queues
          warn ":lock_after_execution_period is set to #{@lock_after_execution_period}, but :unique_at_runtime is not set" if @lock_after_execution_period && !@unique_at_runtime
          warn ":unique_in_queue and :unique_across_queues should not be set at the same time, as :unique_across_queues will always supercede :unique_in_queue" if @unique_in_queue && @unique_across_queues
        end
      end
      def to_hash
        {
            logger: logger,
            log_level: log_level,
            arity_for_uniqueness: arity_for_uniqueness,
            lock_after_execution_period: lock_after_execution_period,
            unique_at_runtime: unique_at_runtime,
            unique_in_queue: unique_in_queue,
            unique_across_queues: unique_across_queues
        }
      end
    end
  end
end
