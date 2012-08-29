shared_context 'basic client' do
  let(:client_options) { { :oauth_token => 'token' } }
  let(:client) { Restforce::Client.new client_options }
end
