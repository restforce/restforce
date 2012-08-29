require 'spec_helper'

describe Restforce::Middleware::Authentication do
  include_context 'basic client'

  describe 'authentication' do
    before do
      @requests = [].tap do |requests|
        requests << stub_request(:get, %r{/services/data/v24\.0/sobjects}).
          with(:headers => {'Authorization' => 'OAuth bad_token'}).
          to_return(:status => 401, :body => fixture(:expired_session_response))

        requests << stub_request(:get, "https://login.salesforce.com/services/oauth2" \
          "/authorize?client_id=#{client_options[:client_id]}&client_secret=" \
          "#{client_options[:client_secret]}&grant_type=password&password=" \
          "#{client_options[:password]}&username=#{client_options[:username]}").
          to_return(:status => 200, :body => fixture(:auth_success_response))

        requests << stub_request(:get, %r{/services/data/v24\.0/sobjects}).
          with(:headers => {'Authorization' => "OAuth #{oauth_token}"}).
          to_return(:status => 200)
      end

      client.get '/services/data/v24.0/sobjects'
    end

    after do
      @requests.each { |request| request.should have_been_requested.once }
    end

    context 'when a username and password is set' do
      let(:client_options) { base_options.merge(:oauth_token => 'bad_token') }

      describe 'the client options' do
        subject { client.instance_variable_get :@options }

        its([:instance_url]) { should eq 'https://na1.salesforce.com' }
        its([:oauth_token]) { should eq oauth_token }
      end
    end
  end
end
