require 'simplecov'
SimpleCov.start

require 'bundler/setup'
Bundler.require :default, :test
require 'faye' unless RUBY_PLATFORM == 'java'

require 'webmock/rspec'

WebMock.disable_net_connect!

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.before do
    EventMachine.stub(:connect) if defined?(EventMachine)
  end

  config.around :eventmachine => true do |example|
    EM.run {
      example.run
      EM.stop
    }
  end
end

