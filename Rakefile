require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rdoc/task'
require 'standard/rake'
require 'yard'

Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb", "bin/**/*")
  rd.title = 'Snibbets'
end

YARD::Rake::YardocTask.new do |t|
 t.files = ['lib/na/*.rb']
 t.options = ['--markup-provider=redcarpet', '--markup=markdown', '--no-private', '-p', 'yard_templates']
 # t.stats_options = ['--list-undoc']
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--pattern {spec,lib}/**/*_spec.rb"
end

task default: %i[test]

desc 'Alias for build'
task :package => :build

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

desc 'Development version check'
task :ver do
  gver = `git ver`
  cver = IO.read(File.join(File.dirname(__FILE__), 'CHANGELOG.md')).match(/^#+ (\d+\.\d+\.\d+(\w+)?)/)[1]
  res = `grep VERSION lib/snibbets/version.rb`
  version = res.match(/VERSION *= *['"](\d+\.\d+\.\d+(\w+)?)/)[1]
  puts "git tag: #{gver}"
  puts "version.rb: #{version}"
  puts "changelog: #{cver}"
end

desc 'Changelog version check'
task :cver do
  puts IO.read(File.join(File.dirname(__FILE__), 'CHANGELOG.md')).match(/^#+ (\d+\.\d+\.\d+(\w+)?)/)[1]
end

desc 'Bump incremental version number'
task :bump, :type do |_, args|
  args.with_defaults(type: 'inc')
  version_file = 'lib/snibbets/version.rb'
  content = IO.read(version_file)
  content.sub!(/VERSION = '(?<major>\d+)\.(?<minor>\d+)\.(?<inc>\d+)(?<pre>\S+)?'/) do
    m = Regexp.last_match
    major = m['major'].to_i
    minor = m['minor'].to_i
    inc = m['inc'].to_i
    pre = m['pre']

    case args[:type]
    when /^maj/
      major += 1
      minor = 0
      inc = 0
    when /^min/
      minor += 1
      inc = 0
    else
      inc += 1
    end

    $stdout.puts "At version #{major}.#{minor}.#{inc}#{pre}"
    "VERSION = '#{major}.#{minor}.#{inc}#{pre}'"
  end
  File.open(version_file, 'w+') { |f| f.puts content }
end
