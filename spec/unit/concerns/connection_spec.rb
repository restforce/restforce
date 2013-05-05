require 'spec_helper'

describe Restforce::Concerns::Connection do
  describe '.middleware' do
    subject       { client.middleware }
    let(:builder) { double('Faraday::Builder') }

    before do
      client.stub_chain :connection, :builder => builder
    end

    it { should eq builder }
  end
end