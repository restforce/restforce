# frozen_string_literal: true

require 'simplecov'

if ENV['CI']
  require 'simplecov-lcov'

  SimpleCov::Formatter::LcovFormatter.config do |config|
    config.report_with_single_file = true
    config.single_report_path = 'coverage/lcov.info'
  end

  SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter
end

SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/bundle/'
end
