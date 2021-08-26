# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'bundler/setup'
Bundler.require :default, :test
require 'faye' unless RUBY_PLATFORM == 'java'

require 'webmock/rspec'
require 'rspec/collection_matchers'
require 'rspec/its'

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.order = 'random'
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  original_stderr = $stderr
  original_stdout = $stdout
  config.before(:all) do
    # Redirect stderr and stdout
    $stderr = File.open(File::NULL, "w")
    $stdout = File.open(File::NULL, "w")
  end
  config.after(:all) do
    $stderr = original_stderr
    $stdout = original_stdout
  end

  config.expect_with :rspec do |expectations|
    expectations.syntax = %i[expect should]
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = %i[expect should]
  end
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
paths = Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")]
paths.sort.each { |f| require f }
