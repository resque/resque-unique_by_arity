# frozen_string_literal: true

require "spec_helper"

RSpec.describe Resque::UniqueByArity::Configuration do
  describe "#validate_arity" do
    # rubocop:disable RSpec/ExampleLength
    it "reports a fixed-arity method that cannot satisfy the configured arity" do
      method = Class.new do
        def self.perform(_arg)
        end
      end.method(:perform)
      configuration = described_class.new(arity_for_uniqueness: 2, arity_validation: :error)

      expect { configuration.validate_arity("FixedJob", method) }.to raise_error(
        ArgumentError,
        "FixedJob.perform has arity of 1 which will not work with arity_for_uniqueness of 2"
      )
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
