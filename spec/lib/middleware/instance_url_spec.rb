require 'spec_helper'

describe Restforce::Middleware::InstanceURL do
  include_context 'basic client'

  context 'when the instance url is missing' do
    let(:client_options) { base_options.merge(:instance_url => nil) }

    it 'raises an exception' do
      expect {
        client.get '/foo'
      }.to_not raise_error URI::InvalidURIError
    end
  end
end
