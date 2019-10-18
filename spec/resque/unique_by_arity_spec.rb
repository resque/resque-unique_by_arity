require 'spec_helper'

RSpec.describe Resque::UniqueByArity do
  it 'has a version number' do
    expect(Resque::UniqueByArity::VERSION).not_to be nil
  end

  context 'configuration' do
    before do
      Resque::UniqueByArity::GlobalConfiguration.instance.reset
    end
    it 'has default logger' do
      expect(Resque::UniqueByArity.configuration.logger).to eq(nil)
    end
    it 'has default log_level' do
      expect(Resque::UniqueByArity.configuration.log_level).to eq(:debug)
    end
    it 'has default arity_for_uniqueness' do
      expect(Resque::UniqueByArity.configuration.arity_for_uniqueness).to eq(nil)
    end
    it 'has default arity_for_uniqueness_at_runtime' do
      expect(Resque::UniqueByArity.configuration.arity_for_uniqueness_at_runtime).to eq(nil)
    end
    it 'has default arity_for_uniqueness_in_queue' do
      expect(Resque::UniqueByArity.configuration.arity_for_uniqueness_in_queue).to eq(nil)
    end
    it 'has default arity_for_uniqueness_across_queues' do
      expect(Resque::UniqueByArity.configuration.arity_for_uniqueness_across_queues).to eq(nil)
    end
    it 'has default arity_validation' do
      expect(Resque::UniqueByArity.configuration.arity_validation).to eq(nil)
    end
    it 'has default lock_after_execution_period' do
      expect(Resque::UniqueByArity.configuration.lock_after_execution_period).to eq(0)
    end
    it 'has default runtime_lock_timeout' do
      expect(Resque::UniqueByArity.configuration.runtime_lock_timeout).to eq(60 * 60 * 24 * 5)
    end
    it 'has default runtime_requeue_interval' do
      expect(Resque::UniqueByArity.configuration.runtime_requeue_interval).to eq(1)
    end
    it 'has default unique_at_runtime_key_base' do
      expect(Resque::UniqueByArity.configuration.unique_at_runtime_key_base).to eq('r-uar')
    end
    it 'has default unique_in_queue_key_base' do
      expect(Resque::UniqueByArity.configuration.unique_in_queue_key_base).to eq('r-uiq')
    end
    it 'has default unique_at_runtime' do
      expect(Resque::UniqueByArity.configuration.unique_at_runtime).to eq(false)
    end
    it 'has default unique_in_queue' do
      expect(Resque::UniqueByArity.configuration.unique_in_queue).to eq(false)
    end
    it 'has default unique_across_queues' do
      expect(Resque::UniqueByArity.configuration.unique_across_queues).to eq(false)
    end
    it 'has default ttl' do
      expect(Resque::UniqueByArity.configuration.ttl).to eq(-1)
    end
    it 'has default debug_mode' do
      expect(Resque::UniqueByArity.configuration.debug_mode).to eq(false)
    end

    context 'global' do
      let(:logger) { Logger.new('/dev/null') }
      let(:log_level) { :info }
      let(:arity_for_uniqueness) { 3 }
      let(:arity_for_uniqueness_at_runtime) { 1 }
      let(:arity_for_uniqueness_in_queue) { 3 }
      let(:arity_for_uniqueness_across_queues) { 3 }
      let(:unique_at_runtime) { true }
      let(:unique_in_queue) { true }
      let(:runtime_lock_timeout) { 10 }
      let(:runtime_requeue_interval) { 4 }
      let(:unique_at_runtime_key_base) { 'abc' }
      let(:lock_after_execution_period) { 7 }
      let(:ttl) { 2 }
      let(:unique_in_queue_key_base) { 'def' }
      let(:debug_mode) { true }
      before do
        Resque::UniqueByArity.configure do |config|
          config.logger = logger
          config.log_level = log_level
          config.arity_for_uniqueness = arity_for_uniqueness
          config.arity_for_uniqueness_at_runtime = arity_for_uniqueness_at_runtime
          config.arity_for_uniqueness_in_queue = arity_for_uniqueness_in_queue
          config.arity_for_uniqueness_across_queues = arity_for_uniqueness_across_queues
          config.unique_at_runtime = unique_at_runtime
          config.unique_in_queue = unique_in_queue
          config.runtime_lock_timeout = runtime_lock_timeout
          config.runtime_requeue_interval = runtime_requeue_interval
          config.unique_at_runtime_key_base = unique_at_runtime_key_base
          config.lock_after_execution_period = lock_after_execution_period
          config.ttl = ttl
          config.unique_in_queue_key_base = unique_in_queue_key_base
          # Normally debug mode should be set via an environment variable switch
          #   rather than in the configure block.
          config.debug_mode = debug_mode
        end
      end
      after do
        Resque::UniqueByArity::GlobalConfiguration.instance.reset
      end
      it 'sets' do
        expect(Resque::UniqueByArity.configuration.logger).to eq(logger)
        expect(Resque::UniqueByArity.configuration.log_level).to eq(log_level)
        expect(Resque::UniqueByArity.configuration.arity_for_uniqueness).to eq(arity_for_uniqueness)
        expect(Resque::UniqueByArity.configuration.arity_for_uniqueness_at_runtime).to eq(arity_for_uniqueness_at_runtime)
        expect(Resque::UniqueByArity.configuration.arity_for_uniqueness_in_queue).to eq(arity_for_uniqueness_in_queue)
        expect(Resque::UniqueByArity.configuration.arity_for_uniqueness_across_queues).to eq(arity_for_uniqueness_across_queues)
        expect(Resque::UniqueByArity.configuration.unique_at_runtime).to eq(unique_at_runtime)
        expect(Resque::UniqueByArity.configuration.unique_in_queue).to eq(unique_in_queue)
        expect(Resque::UniqueByArity.configuration.runtime_lock_timeout).to eq(runtime_lock_timeout)
        expect(Resque::UniqueByArity.configuration.runtime_requeue_interval).to eq(runtime_requeue_interval)
        expect(Resque::UniqueByArity.configuration.unique_at_runtime_key_base).to eq(unique_at_runtime_key_base)
        expect(Resque::UniqueByArity.configuration.lock_after_execution_period).to eq(lock_after_execution_period)
        expect(Resque::UniqueByArity.configuration.ttl).to eq(ttl)
        expect(Resque::UniqueByArity.configuration.unique_in_queue_key_base).to eq(unique_in_queue_key_base)
        expect(Resque::UniqueByArity.configuration.debug_mode).to eq(debug_mode)
      end
    end
  end

  context 'logging' do
    let(:log_level) { :info }
    let(:logger) { Logger.new('/dev/null') }
    describe '.log' do
      subject { Resque::UniqueByArity.log('warbler', Resque::UniqueByArity::Configuration.new(logger: logger, log_level: :info)) }
      it('logs') do
        expect(logger).to receive(:info).with('warbler')
        block_is_expected.not_to raise_error
      end
    end

    describe '.debug' do
      context 'with debug_mode => true' do
        subject { Resque::UniqueByArity.debug('warbler', Resque::UniqueByArity::Configuration.new(debug_mode: true, logger: logger, log_level: :info)) }
        it('logs') do
          expect(logger).to receive(:debug).with(/R-UBA.*warbler/)
          block_is_expected.not_to raise_error
        end
      end
      context 'with debug_mode => false' do
        subject { Resque::UniqueByArity.debug('warbler', Resque::UniqueByArity::Configuration.new(debug_mode: false, logger: logger, log_level: :info)) }
        it('logs') do
          expect(logger).not_to receive(:debug).with(/R-UBA.*warbler/)
          block_is_expected.not_to raise_error
        end
      end
    end
  end
end
