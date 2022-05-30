# frozen_string_literal: true

source 'https://rubygems.org'
gemspec

# Enable us to explicitly pick a Faraday version when running tests
gem 'faraday', ENV.fetch('FARADAY_VERSION', '~> 1.8.0')
gem 'faye' unless RUBY_PLATFORM == 'java'
gem 'guard-rspec'
gem 'guard-rubocop'
gem 'jruby-openssl', platforms: :jruby
gem 'rake'
gem 'rspec', '~> 3.11.0'
gem 'rspec-collection_matchers', '~> 1.2.0'
gem 'rspec-its', '~> 1.3.0'
gem 'rspec_junit_formatter', '~> 0.5.1'
gem 'rubocop', '~> 1.30.0'
gem 'simplecov', '~> 0.21.2'
gem 'webmock', '~> 3.14.0'
