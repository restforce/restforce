# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/its/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec-its"
  spec.version       = RSpec::Its::VERSION
  spec.authors       = ["The RSpec Development Team"]
  spec.email         = ["maintainers@rspec.info"]
  spec.description   = 'RSpec extension gem for attribute matching'
  spec.summary       = 'Provides "its" method formerly part of rspec-core'
  spec.homepage      = "https://github.com/rspec/rspec-its"
  spec.license       = "MIT"
  spec.required_ruby_version = '> 3.0.0'

  spec.metadata['bug_tracker_uri'] = 'https://github.com/rspec/rspec-its/issues'
  spec.metadata['changelog_uri'] = "https://github.com/rspec/rspec-its/blob/v#{spec.version}/Changelog.md"
  spec.metadata['documentation_uri'] = "https://www.rubydoc.info/gems/rspec-its/#{spec.version}"
  spec.metadata['mailing_list_uri'] = 'https://groups.google.com/forum/#!forum/rspec'
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['source_code_uri'] = 'https://github.com/rspec/rspec-its'

  spec.files         = `git ls-files`.split($/) - %w[cucumber.yml]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'rspec-core', '>= 3.13.0'
  spec.add_dependency 'rspec-expectations', '>= 3.13.0'
end
