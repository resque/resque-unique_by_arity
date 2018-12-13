# frozen_string_literal: true

require 'forwardable'

module Resque
  module UniqueByArity
    class Configuration
      class Validator
        extend Forwardable

        ARITY_FOR_UNIQUENESS_MSG = '[%<job_name>s] :arity_for_uniqueness is set to %<arity_for_uniqueness>d, but no uniqueness enforcement was turned on [:unique_at_runtime, :unique_in_queue, :unique_across_queues]'.freeze
        LOCK_AFTER_EXEC_PERIOD_MSG = '[%<job_name>s] :lock_after_execution_period is set to %<lock_after_execution_period>d, but :unique_at_runtime is not set'.freeze
        RUNTIME_LOCK_TIMEOUT_MSG = '[%<job_name>s] :runtime_lock_timeout is set to %<runtime_lock_timeout>s, but :unique_at_runtime is not set'.freeze
        RUNTIME_REQUEUE_INTERVAL_MSG = '[%<job_name>s] :runtime_requeue_interval is set to %<runtime_requeue_interval>d, but :unique_at_runtime is not set'.freeze
        CONCURRENT_CONFIG_MSG = '[%<job_name>] :unique_in_queue and :unique_across_queues should not be set at the same time, as :unique_across_queues will always supercede :unique_in_queue'.freeze

        private_constant :ARITY_FOR_UNIQUENESS_MSG,
                         :LOCK_AFTER_EXEC_PERIOD_MSG,
                         :RUNTIME_LOCK_TIMEOUT_MSG,
                         :RUNTIME_REQUEUE_INTERVAL_MSG,
                         :CONCURRENT_CONFIG_MSG

        def initialize(config)
          @config = config
        end

        def log_warnings
          validate_arity_for_uniqueness
          validate_after_execution_period
          validate_runtime_lock_timout
          validate_runtime_requeue_interval
        end

        def self.log_warnings(*args)
          new(*args).log_warnings
        end

        private

        attr_reader :config
        def_delegators :config,
                       :arity_for_uniqueness,
                       :base_klass_name,
                       :lock_after_execution_period,
                       :runtime_lock_timeout,
                       :runtime_requeue_interval,
                       :unique_across_queues,
                       :unique_at_runtime,
                       :unique_in_queue

        def log(msg)
          Resque::UniqueByArity.log(msg, config)
        end

        def default_config_value?(config_attr)
          config.send(config_attr) == default_config(config_attr)
        end

        def default_config(attr)
          Resque::UniqueByArity.configuration.send(attr)
        end

        def validate_runtime_requeue_interval
          return if default_config_value?(:runtime_requeue_interval) ||
                    unique_at_runtime

          log format(
            RUNTIME_REQUEUE_INTERVAL_MSG,
            job_name: base_klass_name,
            runtime_requeue_interval: runtime_requeue_interval
          )
        end

        def validate_runtime_lock_timout
          return if default_config_value?(:runtime_lock_timeout) ||
                    unique_at_runtime

          log format(
            RUNTIME_LOCK_TIMEOUT_MSG,
            job_name: base_klass_name,
            runtime_lock_timeout: runtime_lock_timeout
          )
        end

        def validate_after_execution_period
          return if default_config_value?(:lock_after_execution_period) ||
                    (unique_in_queue || unique_across_queues)

          log format(
            LOCK_AFTER_EXEC_PERIOD_MSG,
            job_name: base_klass_name,
            lock_after_execution_period: lock_after_execution_period
          )
        end

        def validate_arity_for_uniqueness
          return if arity_for_uniqueness == 1 ||
                    (unique_at_runtime ||
                     unique_in_queue ||
                     unique_across_queues)

          log format(
            ARITY_FOR_UNIQUENESS_MSG,
            job_name: base_klass_name,
            arity_for_uniqueness: arity_for_uniqueness
          )
        end
      end
    end
  end
end
