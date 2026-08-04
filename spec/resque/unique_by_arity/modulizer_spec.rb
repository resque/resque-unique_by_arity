# frozen_string_literal: true

require "spec_helper"

RSpec.describe Resque::UniqueByArity::Modulizer do
  # These examples exercise generated modules end to end, so each assertion
  # documents a distinct generated API rather than a shared implementation detail.
  # rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
  def job_for(configuration)
    job = Class.new
    job.instance_variable_set(:@queue, :reports)
    job.define_singleton_method(:to_s) { "ModularJob" }
    job.define_singleton_method(:unique_in_queue_key_base) { "r-uiq" }
    job.define_singleton_method(:unique_at_runtime_key_base) { "r-uar" }
    job.extend(described_class.to_mod(configuration))
    job
  end

  before do
    Resque.redis.flushdb
  end

  it "returns an empty module when no uniqueness mode is enabled" do
    configuration = Resque::UniqueByArity::Configuration.new(
      unique_in_queue: false,
      unique_across_queues: false,
      unique_at_runtime: false
    )

    expect(described_class.to_mod(configuration).instance_methods).to be_empty
  end

  it "generates queue and runtime uniqueness methods" do
    configuration = Resque::UniqueByArity::Configuration.new(
      arity_for_uniqueness: 1,
      arity_for_uniqueness_in_queue: 1,
      arity_for_uniqueness_at_runtime: 1,
      unique_in_queue: true,
      unique_at_runtime: true
    )
    job = job_for(configuration)
    payload = {"class" => "ModularJob", "args" => [7, {b: 2, a: 1}]}

    queue_key = job.unique_in_queue_redis_key(:reports, payload)
    runtime_key = job.unique_at_runtime_redis_key(7, {b: 2, a: 1})
    Resque.redis.set(queue_key, "queued")
    Resque.redis.set(runtime_key, "running")

    expect(job.unique_in_queue_key_namespace(:reports)).to eq("r-uiq:queue:reports:job")
    expect(job.purge_unique_queued_redis_keys).to be > 0
    expect(job.purge_unique_at_runtime_redis_keys).to be > 0
    expect(Resque.redis.get(queue_key)).to be_nil
    expect(Resque.redis.get(runtime_key)).to be_nil
  end

  it "generates a shared namespace for cross-queue uniqueness" do
    configuration = Resque::UniqueByArity::Configuration.new(
      arity_for_uniqueness_across_queues: 1,
      unique_across_queues: true
    )
    job = job_for(configuration)

    expect(job.unique_in_queue_key_namespace(:reports)).to eq("r-uiq:across_queues:job")
    expect(job.unique_in_queue_redis_key(:reports, {"class" => "ModularJob", "args" => [7]})).to eq(
      job.unique_in_queue_redis_key(:other, {"class" => "ModularJob", "args" => [7]})
    )
  end

  # rubocop:enable RSpec/ExampleLength, RSpec/MultipleExpectations
end
