# frozen_string_literal: true

require "anonymous_loader"
RSpec.describe Resque::UniqueByArity::Version do
  it_behaves_like "a Version module", described_class

  it "executes the version file for coverage without redefining constants" do
    paths = [
      File.expand_path("../../../lib/resque/unique_by_arity/version.rb", __dir__),
      File.expand_path("../../../lib/resque/unique_by_arity/version_gem.rb", __dir__)
    ].select { |path| File.file?(path) }
    anonymous_namespace = AnonymousLoader.load(files: paths)

    expect(anonymous_namespace::Resque::UniqueByArity::Version::VERSION).to eq(described_class::VERSION)
  end
end
