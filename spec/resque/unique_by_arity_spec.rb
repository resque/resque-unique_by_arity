require "spec_helper"

RSpec.describe Resque::UniqueByArity do
  it "has a version number" do
    expect(Resque::UniqueByArity::VERSION).not_to be nil
  end

  subject {
    Class.new do
      include Resque::UniqueByArity::Cop.new(
          arity_for_uniqueness: 1,
          unique_at_runtime: true,
          unique_in_queue: true
      )
      def self.to_s
        "RealFake"
      end
      def self.perform(_req, _opts = {})
        # Does something
      end
    end
  }
  let(:opts) { { } }
  let(:args) { [ 1, opts ] }
  context ".redis_unique_hash" do
    context "with company id 1" do
      it "should give ['ef0f8a28f2c84e48211489121112e67f', [1]]" do
        expect(subject.redis_unique_hash({ class: subject.to_s, args: args })).to eq ["ef0f8a28f2c84e48211489121112e67f", [1]]
      end
    end
  end
  context ".solo_redis_key_prefix" do
    it "should give unique_job:RealFake" do
      expect(subject.solo_redis_key_prefix).to eq "unique_job:RealFake"
    end
  end
  context ".solo_key_namespace" do
    context "with bogus queue" do
      it "should give solo:queue:bogus:job" do
        expect(subject.solo_key_namespace('bogus')).to eq "solo:queue:bogus:job"
      end
    end
  end
  context ".unique_at_queue_time_redis_key" do
    context "with bogus queue" do
      it "should give solo:queue:bogus:job:unique_job:RealFake:ef0f8a28f2c84e48211489121112e67f" do
        expect(subject.unique_at_queue_time_redis_key('bogus', { class: subject.to_s, args: args })).to eq "solo:queue:bogus:job:unique_job:RealFake:ef0f8a28f2c84e48211489121112e67f"
      end
    end
  end
  context ".runtime_key_namespace" do
    it "should give unique_at_runtime:RealFake" do
      expect(subject.runtime_key_namespace).to eq "unique_at_runtime:RealFake"
    end
  end
  context ".unique_at_runtime_redis_key" do
    it "should give unique_at_runtime:RealFake:ef0f8a28f2c84e48211489121112e67f" do
      expect(subject.unique_at_runtime_redis_key(*args)).to eq "unique_at_runtime:RealFake:ef0f8a28f2c84e48211489121112e67f"
    end
  end
  context "invalid arity_for_uniqueness" do
    context "arity_validation is nil" do
      let(:arity_validation) { nil }
      context "no required params, arity high" do
        subject {
          Class.new do
            include Resque::UniqueByArity::Cop.new(
                arity_for_uniqueness: 2,
                arity_validation: nil,
                unique_at_runtime: true,
                unique_in_queue: true
            )
            def self.to_s
              "RealFake"
            end
            def self.perform(_opts = {})
              # Does something
            end
          end
        }
        let(:args) { [ opts ] }
        it "skips validation" do
          expect(Resque::UniqueByArity).to_not receive(:unique_log)
          expect { subject.perform(*args) }.to_not raise_error
        end
      end
      context "not enough required params, arity high" do
        subject {
          Class.new do
            include Resque::UniqueByArity::Cop.new(
                arity_for_uniqueness: 2,
                arity_validation: nil,
                unique_at_runtime: true,
                unique_in_queue: true
            )
            def self.to_s
              "RealFake"
            end
            def self.perform(_req, _opts = {})
              # Does something
            end
          end
        }
        let(:args) { [ 1, opts ] }
        it "skips validation" do
          expect(Resque::UniqueByArity).to_not receive(:unique_log)
          expect { subject.perform(*args) }.to_not raise_error
        end
      end
      context "no params, arity zero" do
        subject {
          Class.new do
            include Resque::UniqueByArity::Cop.new(
                arity_for_uniqueness: 0,
                arity_validation: nil,
                unique_at_runtime: true,
                unique_in_queue: true
            )
            def self.to_s
              "RealFake"
            end
            def self.perform()
              # Does something
            end
          end
        }
        let(:args) { [ ] }
        it "skips validation" do
          expect(Resque::UniqueByArity).to_not receive(:unique_log)
          expect { subject.perform(*args) }.to_not raise_error
        end
      end
    end
    context "arity_validation is false" do
      let(:arity_validation) { false }
      context "no required params, arity high" do
        subject {
          Class.new do
            include Resque::UniqueByArity::Cop.new(
                arity_for_uniqueness: 2,
                arity_validation: nil,
                unique_at_runtime: true,
                unique_in_queue: true
            )
            def self.to_s
              "RealFake"
            end
            def self.perform(_opts = {})
              # Does something
            end
          end
        }
        let(:args) { [ opts ] }
        it "skips validation" do
          expect(Resque::UniqueByArity).to_not receive(:unique_log)
          expect { subject.perform(*args) }.to_not raise_error
        end
      end
      context "not enough required params, arity high" do
        subject {
          Class.new do
            include Resque::UniqueByArity::Cop.new(
                arity_for_uniqueness: 2,
                arity_validation: nil,
                unique_at_runtime: true,
                unique_in_queue: true
            )
            def self.to_s
              "RealFake"
            end
            def self.perform(_req, _opts = {})
              # Does something
            end
          end
        }
        let(:args) { [ 1, opts ] }
        it "skips validation" do
          expect(Resque::UniqueByArity).to_not receive(:unique_log)
          expect { subject.perform(*args) }.to_not raise_error
        end
      end
      context "no params, arity zero" do
        subject {
          Class.new do
            include Resque::UniqueByArity::Cop.new(
                arity_for_uniqueness: 0,
                arity_validation: nil,
                unique_at_runtime: true,
                unique_in_queue: true
            )
            def self.to_s
              "RealFake"
            end
            def self.perform()
              # Does something
            end
          end
        }
        let(:args) { [ ] }
        it "skips validation" do
          expect(Resque::UniqueByArity).to_not receive(:unique_log)
          expect { subject.perform(*args) }.to_not raise_error
        end
      end
    end
    context "arity_validation is :warning" do
      let(:arity_validation) { :warning }
      context "no required params, arity high" do
        subject {
          Class.new do
            include Resque::UniqueByArity::Cop.new(
                arity_for_uniqueness: 2,
                arity_validation: :warning,
                unique_at_runtime: true,
                unique_in_queue: true
            )
            def self.to_s
              "RealFake"
            end
            def self.perform(_opts = {})
              # Does something
            end
          end
        }
        let(:args) { [ opts ] }
        it "fails validation" do
          expect(Resque::UniqueByArity).to receive(:unique_log).with("RealFake.perform has arity of -1 which will not work with arity_for_uniqueness of 2", anything)
          expect { subject.perform(*args) }.to_not raise_error
        end
      end
      context "not enough required params, arity high" do
        subject {
          Class.new do
            include Resque::UniqueByArity::Cop.new(
                arity_for_uniqueness: 2,
                arity_validation: :warning,
                unique_at_runtime: true,
                unique_in_queue: true
            )
            def self.to_s
              "RealFake"
            end
            def self.perform(_req, _opts = {})
              # Does something
            end
          end
        }
        let(:args) { [ 1, opts ] }
        it "fails validation" do
          expect(Resque::UniqueByArity).to receive(:unique_log).with("RealFake.perform has arity of -2 which will not work with arity_for_uniqueness of 2", anything)
          expect { subject.perform(*args) }.to_not raise_error
        end
      end
      context "no params, arity zero" do
        subject {
          Class.new do
            include Resque::UniqueByArity::Cop.new(
                arity_for_uniqueness: 0,
                arity_validation: :warning,
                unique_at_runtime: true,
                unique_in_queue: true
            )
            def self.to_s
              "RealFake"
            end
            def self.perform()
              # Does something
            end
          end
        }
        let(:args) { [ ] }
        it "passes validation" do
          expect(Resque::UniqueByArity).to_not receive(:unique_log).with('')
          expect { subject.perform(*args) }.to_not raise_error
        end
      end
    end
    context "arity_validation is :error" do
      let(:arity_validation) { :error }
      context "no required params, arity high" do
        subject {
          Class.new do
            include Resque::UniqueByArity::Cop.new(
                arity_for_uniqueness: 2,
                arity_validation: :error,
                unique_at_runtime: true,
                unique_in_queue: true
            )
            def self.to_s
              "RealFake"
            end
            def self.perform(_opts = {})
              # Does something
            end
          end
        }
        let(:args) { [ opts ] }
        it "fails validation" do
          expect(Resque::UniqueByArity).to_not receive(:unique_log)
          expect { subject.perform(*args) }.to raise_error ArgumentError, "RealFake.perform has arity of -1 which will not work with arity_for_uniqueness of 2"
        end
      end
      context "not enough required params, arity high" do
        subject {
          Class.new do
            include Resque::UniqueByArity::Cop.new(
                arity_for_uniqueness: 2,
                arity_validation: :error,
                unique_at_runtime: true,
                unique_in_queue: true
            )
            def self.to_s
              "RealFake"
            end
            def self.perform(_req, _opts = {})
              # Does something
            end
          end
        }
        let(:args) { [ 1, opts ] }
        it "fails validation" do
          expect(Resque::UniqueByArity).to_not receive(:unique_log)
          expect { subject.perform(*args) }.to raise_error ArgumentError, "RealFake.perform has arity of -2 which will not work with arity_for_uniqueness of 2"
        end
      end
      context "no params, arity zero" do
        subject {
          Class.new do
            include Resque::UniqueByArity::Cop.new(
                arity_for_uniqueness: 0,
                arity_validation: :error,
                unique_at_runtime: true,
                unique_in_queue: true
            )
            def self.to_s
              "RealFake"
            end
            def self.perform()
              # Does something
            end
          end
        }
        let(:args) { [ ] }
        it "passes validation" do
          expect(Resque::UniqueByArity).to_not receive(:unique_log)
          expect { subject.perform(*args) }.to_not raise_error
        end
      end
    end
    context "arity_validation is an error class" do
      let(:arity_validation) { RuntimeError }
      context "no required params, arity high" do
        subject {
          Class.new do
            include Resque::UniqueByArity::Cop.new(
                arity_for_uniqueness: 2,
                arity_validation: RuntimeError,
                unique_at_runtime: true,
                unique_in_queue: true
            )
            def self.to_s
              "RealFake"
            end
            def self.perform(_opts = {})
              # Does something
            end
          end
        }
        let(:args) { [ opts ] }
        it "fails validation" do
          expect(Resque::UniqueByArity).to_not receive(:unique_log)
          expect { subject.perform(*args) }.to raise_error RuntimeError, "RealFake.perform has arity of -1 which will not work with arity_for_uniqueness of 2"
        end
      end
      context "not enough required params, arity high" do
        subject {
          Class.new do
            include Resque::UniqueByArity::Cop.new(
                arity_for_uniqueness: 2,
                arity_validation: RuntimeError,
                unique_at_runtime: true,
                unique_in_queue: true
            )
            def self.to_s
              "RealFake"
            end
            def self.perform(_req, _opts = {})
              # Does something
            end
          end
        }
        let(:args) { [ 1, opts ] }
        it "fails validation" do
          expect(Resque::UniqueByArity).to_not receive(:unique_log)
          expect { subject.perform(*args) }.to raise_error RuntimeError, "RealFake.perform has arity of -2 which will not work with arity_for_uniqueness of 2"
        end
      end
      context "no params, arity zero" do
        subject {
          Class.new do
            include Resque::UniqueByArity::Cop.new(
                arity_for_uniqueness: 0,
                arity_validation: RuntimeError,
                unique_at_runtime: true,
                unique_in_queue: true
            )
            def self.to_s
              "RealFake"
            end
            def self.perform()
              # Does something
            end
          end
        }
        let(:args) { [ ] }
        it "passes validation" do
          expect(Resque::UniqueByArity).to_not receive(:unique_log)
          expect { subject.perform(*args) }.to_not raise_error
        end
      end
    end
  end
end
