require 'bundler/setup'
Bundler.require :default, :test

require 'webmock/rspec'

WebMock.disable_net_connect!
