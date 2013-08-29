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

  describe 'private #connection' do
    describe ':mashify option' do
      before(:each) do
        client.stub(:authentication_middleware)
        client.stub(:cache)
      end

      describe 'with mashify not specified' do
        before(:each) do
          client.stub(:options).and_return({})
        end

        it 'includes the Mashify middleware' do
          client.middleware.handlers.index(Restforce::Middleware::Mashify).
              should_not be_nil
        end
      end

      describe 'with mashify=true' do
        before(:each) do
          client.stub(:options).and_return(:mashify => true)
        end

        it 'includes the Mashify middleware' do
          client.middleware.handlers.index(Restforce::Middleware::Mashify).
              should_not be_nil
        end
      end

      describe 'without mashify' do
        before(:each) do
          client.stub(:options).and_return(:mashify => false)
        end

        it 'does not include the Mashify middleware' do
          client.middleware.handlers.index(Restforce::Middleware::Mashify).
              should be_nil
        end
      end
    end
  end
end