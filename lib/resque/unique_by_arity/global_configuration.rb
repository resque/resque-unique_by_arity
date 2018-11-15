require 'logger'
module Resque
  module UniqueByArity
    # This class is for configurations that are app-wide, *not per job class.
    # For this reason it is a Singleton.
    # Will be used as the default settings for the per-job configs.
    class GlobalConfiguration < Configuration
      DEFAULT_LOG_LEVEL = :debug
      DEFAULT_AT_RUNTIME_KEY_BASE = 'r-uar'.freeze
      DEFAULT_IN_QUEUE_KEY_BASE = 'r-uiq'.freeze

      # For resque-unique_at_runtime
      DEFAULT_LOCK_TIMEOUT = 60 * 60 * 24 * 5
      DEFAULT_REQUEUE_INTERVAL = 1
      DEFAULT_UNIQUE_AT_RUNTIME_KEY_BASE = 'r-uar'.freeze

      # For resque-unique_in_queue
      DEFAULT_LOCK_AFTER_EXECUTION_PERIOD = 0
      DEFAULT_TTL = -1
      DEFAULT_UNIQUE_IN_QUEUE_KEY_BASE = 'r-uiq'.freeze

      include Singleton

      def initialize
        debug_mode_from_env
        @logger = nil
        @log_level = DEFAULT_LOG_LEVEL
        @arity_for_uniqueness = nil
        @arity_validation = nil
        @lock_after_execution_period = DEFAULT_LOCK_AFTER_EXECUTION_PERIOD
        @runtime_lock_timeout = DEFAULT_LOCK_TIMEOUT
        @runtime_requeue_interval = DEFAULT_REQUEUE_INTERVAL
        @unique_at_runtime_key_base = DEFAULT_AT_RUNTIME_KEY_BASE
        @unique_in_queue_key_base = DEFAULT_IN_QUEUE_KEY_BASE
        @unique_at_runtime = false
        @unique_at_runtime_key_base = DEFAULT_UNIQUE_AT_RUNTIME_KEY_BASE
        @unique_in_queue_key_base = DEFAULT_UNIQUE_IN_QUEUE_KEY_BASE
        @unique_in_queue = false
        @unique_across_queues = false
        @ttl = DEFAULT_TTL
        if @debug_mode
          # Make sure there is a logger when in debug_mode
          @logger ||= Logger.new(STDOUT)
        end
      end

      def defcon(sym)
        self.send(sym)
      end
    end
  end
end
