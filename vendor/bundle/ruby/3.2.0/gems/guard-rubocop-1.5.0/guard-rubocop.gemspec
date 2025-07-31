# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'guard/rubocop/version'

Gem::Specification.new do |spec|
  spec.name          = 'guard-rubocop'
  spec.version       = GuardRuboCopVersion.to_s
  spec.authors       = ['Yuji Nakayama']
  spec.email         = ['nkymyj@gmail.com']
  spec.summary       = 'Guard plugin for RuboCop'
  spec.description   = 'Guard::RuboCop automatically checks Ruby code style with RuboCop ' \
                       'when files are modified.'
  spec.homepage      = 'https://github.com/rubocop/guard-rubocop'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.5'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^spec\//)
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'guard',   '~> 2.0'
  spec.add_runtime_dependency 'rubocop', '< 2.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'guard-rspec', '>= 4.2.3', '< 5.0'
  spec.add_development_dependency 'launchy',     '~> 2.4'
  spec.add_development_dependency 'rake',        '>= 12.0'
  spec.add_development_dependency 'rspec',       '~> 3.0'
  spec.add_development_dependency 'simplecov',   '~> 0.7'
end
