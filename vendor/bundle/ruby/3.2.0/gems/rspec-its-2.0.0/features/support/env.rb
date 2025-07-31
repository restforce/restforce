# frozen_string_literal: true

require 'aruba/cucumber'
require 'rspec/core'
require 'rspec/its'

if RUBY_PLATFORM == 'java'
  Aruba.configure do |config|
    config.before(:command) do |cmd|
      # disable JIT since these processes are so short lived
      cmd.environment['JRUBY_OPTS'] = "-X-C #{ENV.fetch('JRUBY_OPTS', '')}"
    end
  end
end
