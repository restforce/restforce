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
  gem.name          = "restforce"
  gem.require_paths = ["lib"]
  gem.version       = Restforce::VERSION

  gem.metadata = {
    'source_code_uri' => 'https://github.com/restforce/restforce',
    'changelog_uri'   => 'https://github.com/restforce/restforce/blob/master/CHANGELOG.md',
'rubygems_mfa_required' => 'true'
  }

  gem.required_ruby_version = '>= 2.6'

  gem.add_dependency 'faraday', '< 2.4', '>= 0.9.0'
  gem.add_dependency 'hashie', '>= 1.2.0', '< 6.0'
  gem.add_dependency 'jwt', ['>= 1.5.6']
end
