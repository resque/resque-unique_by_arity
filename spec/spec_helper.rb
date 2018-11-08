require 'bundler/setup'

require 'byebug' if RbConfig::CONFIG['RUBY_INSTALL_NAME'] == 'ruby'
require 'rspec/block_is_expected'
require 'rspec/stubbed_env'

require 'simplecov'
SimpleCov.start

# This gem
require 'resque/unique_by_arity'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  RSpec.shared_context "resque_debug" do
    include_context 'with stubbed env'
    let(:resque_debug) { 'runtime' }
    before do
      stub_env('RESQUE_DEBUG' => resque_debug)
    end
  end
  config.include_context "resque_debug", :env_resque_stubbed => true
end
