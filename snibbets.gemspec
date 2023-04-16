# frozen_string_literal: true

require_relative "lib/snibbets/version"

Gem::Specification.new do |spec|
  spec.name = "snibbets"
  spec.version = Snibbets::VERSION
  spec.author = "Brett Terpstra"
  spec.email = "me@brettterpstra.com"

  spec.summary = "Snibbets"
  spec.description = "A plain text code snippet manager"
  spec.homepage = "https://github.com/ttscoff/snibbets"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["bug_tracker_uri"] = "#{spec.metadata["source_code_uri"]}/issues"
  spec.metadata["changelog_uri"] = "#{spec.metadata["source_code_uri"]}/blob/main/CHANGELOG.md"
  spec.metadata["github_repo"] = "git@github.com:ttscoff/snibbets.git"

  spec.require_paths << 'lib'
  spec.extra_rdoc_files = ['README.md']
  spec.rdoc_options << '--title' << 'na' << '--main' << 'README.md' << '--markup' << 'markdown'

  spec.bindir = "bin"
  spec.executables << 'snibbets'

  spec.files = Dir["lib/**/*.rb"].reject { |f| f.end_with?("_spec.rb") }
  spec.files += Dir["lib/themes/*.theme"]
  spec.files += Dir["[A-Z]*"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "awesome_print", "~> 1.9"
  spec.add_development_dependency "gem-release", "~> 2.2"
  spec.add_development_dependency "parse_gemspec-cli", "~> 1.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency 'rdoc', '~> 6.3.1'
  spec.add_development_dependency 'yard', '~> 0.9', '>= 0.9.26'
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov", "~> 0.21"
  spec.add_development_dependency "simplecov-console", "~> 0.9"
  spec.add_development_dependency "standard", "~> 1.3"
  spec.add_runtime_dependency 'tty-which', '~> 0.5', '>= 0.5.0'
  spec.add_runtime_dependency('tty-reader', '~> 0.9', '>= 0.9.0')
  spec.add_runtime_dependency('mdless', '~> 1.0', '>= 1.0.32')
end
