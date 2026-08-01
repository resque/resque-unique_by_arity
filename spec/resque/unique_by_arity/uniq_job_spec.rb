require "spec_helper"

RSpec.describe Resque::UniqueByArity::UniqueJob do
  subject { instance }

  let(:logger) { Logger.new("/dev/null") }
  let(:log_level) { :info }
  let(:debug_mode) { false }
  let(:config) do
    Resque::UniqueByArity::Configuration.new(
      logger: logger,
      log_level: log_level,
      debug_mode: debug_mode
    )
  end
  let(:instance) do
    Class.new do
      def self.to_s
        "RealFake"
      end

      def self.perform(_req, _opts = {})
        # Does something
      end
      include Resque::Plugins::UniqueByArity.new(
        arity_for_uniqueness: 1,
        unique_at_runtime: true,
        unique_in_queue: true
      )
    end
  end

  let(:opts) { {} }
  let(:args) { [1, opts] }

  describe ".uniq_log" do
    subject { instance.uniq_log(message, config) }

    let(:message) { "warbler" }

    context "logger is set" do
      it "logs" do
        expect(logger).to receive(log_level).with(message)
        subject
      end
    end

    context "logger is not set" do
      let(:logger) { nil }

      it "does not log" do
        expect(logger).not_to receive(log_level)
        subject
      end
    end
  end

  describe ".uniq_debug" do
    subject { instance.uniq_debug(message, config) }

    let(:message) { "warbler" }

    context "logger is set" do
      context "debug_mode is on" do
        let(:debug_mode) { true }

        it "logs to debug" do
          expect(logger).not_to receive(log_level)
          expect(logger).to receive(:debug).with("#{Resque::UniqueByArity::PLUGIN_TAG}#{message}")
          subject
        end
      end

      context "debug_mode is off" do
        let(:debug_mode) { false }

        it "does not log" do
          expect(logger).not_to receive(log_level)
          expect(logger).not_to receive(:debug)
          subject
        end
      end
    end

    context "logger is not set" do
      let(:logger) { nil }

      it "does not log" do
        expect(logger).not_to receive(log_level)
        expect(logger).not_to receive(:debug)
        subject
      end
    end
  end

  describe ".uniqueness_configure" do
    let(:new_log_level) { :error }

    before { instance.uniqueness_configure { |config| config.log_level = new_log_level } }

    it "sets" do
      expect(instance.uniq_config.log_level).to eq(new_log_level)
    end
  end

  describe ".uniqueness_config_reset" do
    subject { instance.uniqueness_config_reset }

    it "sets to defaults" do
      subject
      expect(instance.uniq_config.log_level).to eq(:debug)
    end

    context "with custom config" do
      subject { instance.uniqueness_config_reset(config) }

      it "sets to defaults" do
        subject
        expect(instance.uniq_config.log_level).to eq(:info)
      end
    end
  end

  describe ".uniq_config" do
    subject { instance.uniq_config }

    before do
      instance.uniqueness_config_reset(config)
    end

    it "returns config" do
      expect(subject).to eq(config)
    end
  end
end
