# frozen_string_literal: true

require File.expand_path('lib/restforce/version', __dir__)

Gem::Specification.new do |gem|
  gem.authors       = ["Eric J. Holmes", "Tim Rogers"]
  gem.email         = ["eric@ejholmes.net", "tim@gocardless.com"]
  gem.description   = 'A lightweight ruby client for the Salesforce REST API.'
  gem.summary       = 'A lightweight ruby client for the Salesforce REST API.'
  gem.homepage      = "http://restforce.org/"
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

  gem.required_ruby_version = '>= 2.4'

  gem.add_dependency 'faraday', '< 1.1', '>= 0.9.0'
  gem.add_dependency 'faraday_middleware', ['>= 0.8.8', '< 1.1']

  gem.add_dependency 'json', '>= 1.7.5'
  gem.add_dependency 'jwt', ['>= 1.5.6']

  gem.add_dependency 'hashie', '>= 1.2.0', '< 5.0'

  gem.add_development_dependency 'faye' unless RUBY_PLATFORM == 'java'
  gem.add_development_dependency 'rspec', '~> 2.14.0'
  gem.add_development_dependency 'rspec_junit_formatter', '~> 0.4.1'
  gem.add_development_dependency 'rubocop', '~> 0.77.0'
  gem.add_development_dependency 'simplecov', '~> 0.17.1'
  gem.add_development_dependency 'webmock', '~> 3.7.6'
end
