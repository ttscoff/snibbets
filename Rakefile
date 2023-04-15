# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "standard/rake"

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--pattern {spec,lib}/**/*_spec.rb"
end

task default: %i[lint test]

task test: "spec"
task lint: "standard"
task format: "standard:fix"

desc "Open an interactive ruby console"
task :console do
  require "irb"
  require "bundler/setup"
  require "snibbets"
  ARGV.clear
  IRB.start
end
