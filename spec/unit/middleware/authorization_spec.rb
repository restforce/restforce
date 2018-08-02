# frozen_string_literal: true

require 'spec_helper'

describe Restforce::Middleware::Authorization do
  let(:options) { { oauth_token: 'token' } }

  describe '.call' do
    subject { lambda { middleware.call(env) } }

    it { should change { env[:request_headers]['Authorization'] }.to eq 'OAuth token' }
  end
end
