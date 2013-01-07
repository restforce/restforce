require 'spec_helper'

describe Restforce::SignedRequest do
  let(:client_secret) { 'foo' }
  let(:message) do
    digest = OpenSSL::Digest::Digest.new('sha256')
    signature = Base64.encode64(OpenSSL::HMAC.digest(digest, client_secret, data))
    "#{signature}.#{data}"
  end

  describe '.decode' do
    subject { described_class.new(message, client_secret).decode }

    context 'when the message is valid' do
      let(:data) { Base64.encode64('{"key": "value"}') }
      it { should eq('key' => 'value') }
    end

    context 'when the message is invalid' do
      let(:message) { 'foobar.awdkjkj' }
      it { should be_nil }
    end
  end
end
