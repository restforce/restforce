# -*- encoding: utf-8 -*-
require File.expand_path('../lib/restforce/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Eric J. Holmes", "Tim Rogers"]
  gem.email         = ["eric@ejholmes.net", "tim@gocardless.com"]
  gem.description   = %q{A lightweight ruby client for the Salesforce REST API.}
  gem.summary       = %q{A lightweight ruby client for the Salesforce REST API.}
  gem.homepage      = "https://restforce.org/"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "restforce"
  gem.require_paths = ["lib"]
  gem.version       = Restforce::VERSION

  gem.metadata = {
    'source_code_uri' => 'https://github.com/ejholmes/restforce',
    'changelog_uri'   => 'https://github.com/ejholmes/restforce/blob/master/CHANGELOG.md'
  }

  gem.required_ruby_version = '>= 2.0'

  gem.add_dependency 'faraday', ['>= 0.9.0', '<= 1.0']
  gem.add_dependency 'faraday_middleware', ['>= 0.8.8', '<= 1.0']

  gem.add_dependency 'json', '>= 1.7.5'

  gem.add_dependency 'hashie', ['>= 1.2.0', '< 4.0']

  gem.add_development_dependency 'rspec', '~> 2.14.0'
  gem.add_development_dependency 'webmock', '~> 3.0.1'
  gem.add_development_dependency 'simplecov', '~> 0.7.1'
  gem.add_development_dependency 'rubocop', '~> 0.31.0'
  gem.add_development_dependency 'rspec_junit_formatter', '~> 0.3.0'
  gem.add_development_dependency 'faye' unless RUBY_PLATFORM == 'java'
end
