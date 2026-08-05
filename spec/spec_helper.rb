# frozen_string_literal: true

# Config for development dependencies of this library
# i.e., not configured by this library
#
# SimpleCov & related config (must run BEFORE any other requires)
# NOTE: Gemfiles for non-coverage appraisals may not have kettle-soup-cover.
#       The rescue LoadError handles that scenario.
begin
  require "kettle-soup-cover"
  if Kettle::Soup::Cover::DO_COV
    # Requiring simplecov loads the project-local `.simplecov`.
    require "simplecov"
    require "kettle/soup/cover/config"
    SimpleCov.start
  end
rescue LoadError => error
  # check the error message and re-raise when unexpected
  raise error unless error.message.include?("kettle")
end

# External RSpec & related config
require "kettle/test/rspec"
# `kettle/test/rspec` installs harness helpers documented in spec/README.md.
require "bundler/setup"

require "debug" if RbConfig::CONFIG["RUBY_INSTALL_NAME"] == "ruby" && Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.7") && ENV["CI"].nil? && ENV.fetch("DEBUG", "false").casecmp("true").zero?
require "rspec/block_is_expected"
require "rspec/stubbed_env"

SimpleCov.start

# This gem
require "resque-unique_by_arity"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"
  config.expose_dsl_globally = true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  RSpec.shared_context "resque_debug" do
    env_resque_stubbed
    include_context "with stubbed env"
    let(:resque_debug) { "arity" }

    before do
      stub_env("RESQUE_DEBUG" => resque_debug)
    end
  end

  config.include_context "resque_debug", env_resque_stubbed: true
end

RSpec::Mocks.configuration.allow_message_expectations_on_nil = true
