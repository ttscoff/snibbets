# frozen_string_literal: true

# require "simplecov"
# require "simplecov-console"

# SimpleCov.start

require "snibbets"

# SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
#   SimpleCov::Formatter::HTMLFormatter,
#   SimpleCov::Formatter::Console
# ])

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"

  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

RSpec::Matchers.define :have_constant do |const|
  match do |owner|
    owner.const_defined?(const)
  end
end
