shared_examples_for 'authentication middleware' do
  let(:fail_request) do
    stub_request(:get, %r{/services/data/v24\.0/sobjects}).
      with(:headers => {'Authorization' => "OAuth #{expired_token}"}).
      to_return(:status => 401, :body => fixture(:expired_session_response))
  end

  let(:success_request) do
    stub_request(:get, %r{#{instance_url}/services/data/v24\.0/sobjects}).
      with(:headers => {'Authorization' => "OAuth #{oauth_token}"}).
      to_return(:status => 200)
  end

  let(:password_authentication_request) do
    stub_request(:get, "https://login.salesforce.com/services/oauth2" \
      "/authorize?client_id=#{client_options[:client_id]}&client_secret=" \
      "#{client_options[:client_secret]}&grant_type=password&password=" \
      "#{client_options[:password]}&username=#{client_options[:username]}").
      to_return(:status => 200, :body => fixture(:auth_success_response))
  end

  before do
    @requests = [].tap do |requests|
      requests << fail_request
      requests << authentication_request
      requests << success_request
    end

    client.get '/services/data/v24.0/sobjects'
  end

  after do
    @requests.each { |request| request.should have_been_requested.once }
  end
end
