shared_context 'basic client' do
  let(:oauth_token)   { '00Dx0000000BV7z!AR8AQAxo9UfVkh8AlV0Gomt9Czx9LjHnSSpwBMmbRcgKFmxOtvxjTrKW19ye6PE3Ds1eQz3z8jr3W7_VbWmEu4Q8TVGSTHxs' }
  let(:username)      { 'foo'           }
  let(:password)      { 'bar'           }
  let(:client_id)     { 'client_id'     }
  let(:client_secret) { 'client_secret' }

  let(:base_options) do
    {
      :oauth_token   => oauth_token,
      :username      => username,
      :password      => password,
      :client_id     => client_id,
      :client_secret => client_secret
    }
  end

  let(:client_options) { base_options }

  let(:client) { Restforce::Client.new client_options }
end
