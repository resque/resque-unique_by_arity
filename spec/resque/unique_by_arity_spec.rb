require "spec_helper"

RSpec.describe Resque::UniqueByArity do
  it "has a version number" do
    expect(Resque::UniqueByArity::VERSION).not_to be nil
  end
end
