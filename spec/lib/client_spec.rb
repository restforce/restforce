require 'spec_helper'

describe Restforce::Client do
  let(:client_options) { { :oauth_token => 'token' } }
  let(:client) { Restforce::Client.new client_options }
  
  it do
    puts client.send(:connection)
  end
end
