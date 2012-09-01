require 'spec_helper'

describe Restforce::Middleware::RaiseError do
  let(:app)        { double('app') }
  let(:env)        { { status: status, body: JSON.parse(fixture('sobject/query_error_response')) } }
  let(:middleware) { described_class.new app }

  describe '.on_complete' do
    subject { middleware.on_complete(env) }

    context 'when the status code is 404' do
      let(:status) { 404 }
      specify { expect { subject }.to raise_error Faraday::Error::ResourceNotFound, 'INVALID_FIELD: error_message' }
    end

    context 'when the status code is 400' do
      let(:status) { 400 }
      specify { expect { subject }.to raise_error Faraday::Error::ClientError, 'INVALID_FIELD: error_message' }
    end
  end
end
