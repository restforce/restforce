# frozen_string_literal: true

source 'https://rubygems.org'
gemspec

faraday_version = ENV.fetch('FARADAY_VERSION', '~> 1.8.0')

# Enable us to explicitly pick a Faraday version when running tests
gem 'faraday', faraday_version
gem 'faraday-typhoeus', '~> 0.2.1' unless faraday_version.start_with?("~> 1")
gem 'faye' unless RUBY_PLATFORM == 'java'
gem 'guard-rspec'
gem 'guard-rubocop'
gem 'jruby-openssl', platforms: :jruby
gem 'rake'
gem 'rspec', '~> 3.11.0'
gem 'rspec-collection_matchers', '~> 1.2.0'
gem 'rspec-its', '~> 1.3.0'
gem 'rspec_junit_formatter', '~> 0.6.0'
gem 'rubocop', '~> 1.37.0'
gem 'simplecov', '~> 0.21.2'
gem 'webmock', '~> 3.18.1'
