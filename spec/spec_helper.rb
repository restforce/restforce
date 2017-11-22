require 'simplecov'
SimpleCov.start

require 'bundler/setup'
Bundler.require :default, :test

require 'faye' unless RUBY_PLATFORM == 'java'
require 'webmock/rspec'
require 'rspec/its'
#NOTE I think this only helps collection_spec.rb:43, might be worth changing spec and removing
require 'rspec/collection_matchers'

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.order = 'random'
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each { |f| require f }
