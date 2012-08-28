# -*- encoding: utf-8 -*-
require File.expand_path('../lib/restforce/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Eric J. Holmes"]
  gem.email         = ["eric@ejholmes.net"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "restforce"
  gem.require_paths = ["lib"]
  gem.version       = Restforce::VERSION

  gem.add_dependency 'rake'
  gem.add_dependency 'faraday', '~> 0.8.4'
  gem.add_dependency 'faraday_middleware', '~> 0.8.8'
  gem.add_dependency 'json', '~> 1.7.5'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'webmock'
end
