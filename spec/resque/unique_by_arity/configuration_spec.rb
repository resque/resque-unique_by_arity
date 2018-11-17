# frozen_string_literal: true

require 'spec_helper'

describe Resque::UniqueByArity::Configuration do
  context 'logging' do
    let(:log_level) { :info }
    let(:logger) { Logger.new('/dev/null') }
    let(:arity_for_uniqueness) { 0 }
    let(:arity_validation) { :warning }
    let(:lock_after_execution_period) { nil }
    let(:runtime_lock_timeout) { 10 }
    let(:runtime_requeue_interval) { 15 }
    let(:unique_at_runtime) { true }
    let(:unique_at_runtime_key_base) { 'unicorns' }
    let(:unique_in_queue_key_base) { 'mollusks'}
    let(:unique_in_queue) { true }
    let(:unique_across_queues) { false }
    let(:lock_timeout) { 1000 }
    let(:requeue_interval) { 3 }
    let(:base_klass_name) { 'MardiGras' }
    let(:debug_mode) { nil }
    let(:options) do
      {
          logger: logger,
          log_level: log_level,
          arity_for_uniqueness: arity_for_uniqueness,
          arity_validation: arity_validation,
          lock_after_execution_period: lock_after_execution_period,
          runtime_lock_timeout: runtime_lock_timeout,
          runtime_requeue_interval: runtime_requeue_interval,
          unique_at_runtime: unique_at_runtime,
          unique_at_runtime_key_base: unique_at_runtime_key_base,
          unique_in_queue_key_base: unique_in_queue_key_base,
          unique_in_queue: unique_in_queue,
          unique_across_queues: unique_across_queues,
          lock_timeout: lock_timeout,
          requeue_interval: requeue_interval,
          debug_mode: debug_mode
      }
    end
    let(:instance) { Resque::UniqueByArity::Configuration.new(**options) }
    describe "#initialize" do
      subject { instance }
      it 'does not raise' do
        block_is_expected.not_to raise_error
      end
      context 'logger option' do
        subject { instance.logger }
        it 'sets logger' do
          is_expected.to eq(logger)
        end
      end
      context 'log_level option' do
        subject { instance.log_level }
        it 'sets log_level' do
          is_expected.to eq(log_level)
        end
      end
      context 'arity_for_uniqueness option' do
        subject { instance.arity_for_uniqueness }
        it 'sets arity_for_uniqueness' do
          is_expected.to eq(arity_for_uniqueness)
        end
      end
      context 'arity_validation option' do
        subject { instance.arity_validation }
        it 'sets arity_validation' do
          is_expected.to eq(arity_validation)
        end
      end
      context 'lock_after_execution_period option' do
        subject { instance.lock_after_execution_period }
        it 'sets lock_after_execution_period' do
          is_expected.to eq(lock_after_execution_period)
        end
      end
      context 'runtime_lock_timeout option' do
        subject { instance.runtime_lock_timeout }
        it 'sets runtime_lock_timeout' do
          is_expected.to eq(runtime_lock_timeout)
        end
      end
      context 'runtime_requeue_interval option' do
        subject { instance.runtime_requeue_interval }
        it 'sets runtime_requeue_interval' do
          is_expected.to eq(runtime_requeue_interval)
        end
      end
      context 'unique_at_runtime option' do
        subject { instance.unique_at_runtime }
        it 'sets unique_at_runtime' do
          is_expected.to eq(unique_at_runtime)
        end
      end
      context 'unique_at_runtime_key_base option' do
        subject { instance.unique_at_runtime_key_base }
        it 'sets unique_at_runtime_key_base' do
          is_expected.to eq(unique_at_runtime_key_base)
        end
      end
      context 'unique_in_queue option' do
        subject { instance.unique_in_queue }
        it 'sets unique_in_queue' do
          is_expected.to eq(unique_in_queue)
        end
      end
      context 'unique_in_queue_key_base option' do
        subject { instance.unique_in_queue_key_base }
        it 'sets unique_in_queue_key_base' do
          is_expected.to eq(unique_in_queue_key_base)
        end
      end
      context 'unique_across_queues option' do
        subject { instance.unique_across_queues }
        it 'sets unique_across_queues' do
          is_expected.to eq(unique_across_queues)
        end
      end
      context 'debug_mode option' do
        subject { instance.debug_mode }
        it 'sets debug_mode' do
          is_expected.to be(false)
        end
        context 'value giving truthy' do
          let(:debug_mode) { 'truthy' }
          it 'can be set' do
            is_expected.to be(true)
          end
        end
        context 'value giving falsey' do
          let(:debug_mode) { false }
          it 'can be set' do
            is_expected.to be(false)
          end
        end
      end
    end

    describe '#log' do
      subject { instance.log('warbler') }
      it('logs') do
        expect(logger).to receive(:info).with('warbler')
        block_is_expected.not_to raise_error
      end
    end

    describe '#to_hash' do
      subject { instance.to_hash }
      it('does not raise') do
        block_is_expected.not_to raise_error
      end
      it('returns a hash') do
        is_expected.to eq({
                              log_level: :info,
                              logger: logger,
                              arity_for_uniqueness: arity_for_uniqueness,
                              arity_validation: arity_validation,
                              base_klass_name: nil, # Not set by initialize!
                              debug_mode: false, # normalized to true || false
                              lock_after_execution_period: lock_after_execution_period,
                              runtime_lock_timeout: runtime_lock_timeout,
                              ttl: -1,
                              unique_at_runtime: unique_at_runtime,
                              unique_in_queue: unique_in_queue,
                              unique_across_queues: unique_across_queues
                          })
      end
    end

    describe "#base_klass_name" do
      subject { instance.base_klass_name = base_klass_name }
      it 'sets base_klass_name' do
        is_expected.to eq(base_klass_name)
      end
    end
  end
end
