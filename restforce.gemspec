# frozen_string_literal: true

require File.expand_path('lib/restforce/version', __dir__)

Gem::Specification.new do |gem|
  gem.authors       = ["Tim Rogers", "Eric J. Holmes"]
  gem.email         = ["me@timrogers.co.uk", "eric@ejholmes.net"]
  gem.description   = 'A lightweight Ruby client for the Salesforce REST API'
  gem.summary       = 'A lightweight Ruby client for the Salesforce REST API'
  gem.homepage      = "https://restforce.github.io/"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "restforce"
  gem.require_paths = ["lib"]
  gem.version       = Restforce::VERSION

  gem.metadata = {
    'source_code_uri' => 'https://github.com/restforce/restforce',
    'changelog_uri'   => 'https://github.com/restforce/restforce/blob/master/CHANGELOG.md'
  }

  gem.required_ruby_version = '>= 2.5'

  gem.add_dependency 'faraday', '<= 2.0', '>= 0.9.0'
  gem.add_dependency 'faraday_middleware', ['>= 0.8.8', '<= 2.0']

  gem.add_dependency 'jwt', ['>= 1.5.6']

  gem.add_dependency 'hashie', '>= 1.2.0', '< 5.0'

  gem.add_development_dependency 'faye' unless RUBY_PLATFORM == 'java'
  gem.add_development_dependency 'rspec', '~> 2.14.0'
  gem.add_development_dependency 'rspec_junit_formatter', '~> 0.4.1'

  gem.add_development_dependency 'rubocop', '~> 1.18.3'
  gem.add_development_dependency 'simplecov', '~> 0.21.2'
  gem.add_development_dependency 'webmock', '~> 3.13.0'
end
