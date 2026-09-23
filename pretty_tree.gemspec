# frozen_string_literal: true

require_relative "lib/pretty_tree/version"

Gem::Specification.new do |spec|
  spec.name = "pretty_tree"
  spec.version = PrettyTree::VERSION
  spec.authors = ["Riccardo Giomi"]
  spec.email = ["riccardo.giomi.contact@gmail.com"]

  spec.summary = "Renders a tree as a string, prettily."
  spec.description = <<~EOL
    PrettyTree renders tree-shaped data as readable ASCII diagrams.

    Useful in #inspect output, log lines, or anywhere you want to see a tree's structure at a glance instead of a nested inspect dump.

    Works out of the box with nested-array trees, and extends to any node type via a small Adapter/Formatter interface.
  EOL
  spec.homepage = "https://github.com/riccardo-giomi/pretty_tree"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage + "/blob/master/CHANGELOG.md"

  # Uncomment the line below to require MFA for gem pushes.
  # This helps protect your gem from supply chain attacks by ensuring
  # no one can publish a new version without multi-factor authentication.
  # See: https://guides.rubygems.org/mfa-requirement-opt-in/
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .standard.yml .ruby-version])
    end
  end
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://guides.rubygems.org/make-your-own-gem/
end
