# frozen_string_literal: true

require_relative "lib/rails_digger/version"

Gem::Specification.new do |spec|
  spec.name          = "rails_digger"
  spec.version       = RailsDigger::VERSION
  spec.authors       = ["Joran Kikke"]
  spec.email         = ["joran.k@gmail.com"]

  spec.summary       = "Finds as much code as possible then builds a report on how much each bit is used."
  spec.description   = "RailsDigger is a tool designed to analyze Rails applications, listing all defined methods and identifying unused code to help optimize and clean up your codebase."
  spec.homepage      = "https://github.com/dangerousbeans/rails_digger"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = "https://github.com/dangerousbeans/rails_digger"
  spec.metadata["source_code_uri"] = "https://github.com/dangerousbeans/rails_digger"
  spec.metadata["changelog_uri"] = "https://github.com/yourusername/rails_digger/blob/main/CHANGELOG.md" # Replace with actual CHANGELOG URL

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_dependency "parser", "~> 3.0"
  spec.add_dependency "unparser", "~> 0.4"

  # Development dependencies
  spec.add_development_dependency "rspec", "~> 3.10"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
