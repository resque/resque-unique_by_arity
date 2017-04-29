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
      alias :debug_logger :logger
      alias :debug_log_level :log_level
      alias :debug_arity_for_uniqueness :arity_for_uniqueness
      alias :debug_lock_after_execution_period :lock_after_execution_period
      alias :debug_unique_at_runtime :unique_at_runtime
      alias :debug_unique_in_queue :unique_in_queue
      def initialize(**options)
        @logger = options.key?(:logger) ? options[:logger] : Logger.new(STDOUT)
        @log_level = options.key?(:log_level) ? options[:log_level] : :debug
        @arity_for_uniqueness = options.key?(:arity_for_uniqueness) ? options[:arity_for_uniqueness] : 1
        @lock_after_execution_period = options.key?(:lock_after_execution_period) ? options[:lock_after_execution_period] : nil
        @unique_at_runtime = options.key?(:unique_at_runtime) ? options[:unique_at_runtime] : false
        @unique_in_queue = options.key?(:unique_in_queue) ? options[:unique_in_queue] : false
      end
      def to_hash
        {
            logger: logger,
            log_level: log_level,
            arity_for_uniqueness: arity_for_uniqueness,
            lock_after_execution_period: lock_after_execution_period,
            unique_at_runtime: unique_at_runtime,
            unique_in_queue: unique_in_queue
        }
      end
    end
  end
end
