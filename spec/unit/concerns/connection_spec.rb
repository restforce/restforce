# frozen_string_literal: true

require 'spec_helper'

describe Restforce::Concerns::Connection do
  describe '.middleware' do
    subject       { client.middleware }
    let(:builder) { double('Faraday::Builder') }

    before do
      client.stub_chain :connection, builder: builder
    end

    it { should eq builder }
  end

  describe "#connection_options" do
    let(:options) { { ssl: { verify: false } } }
    before { client.stub(options: options) }

    it "picks up passed-in SSL options" do
      expect(client.send(:connection_options)).to include(options)
    end
  end

  describe 'private #connection' do
    describe ':mashify option' do
      let(:options) { { adapter: Faraday.default_adapter } }

      before(:each) do
        client.stub(:authentication_middleware)
        client.stub(:cache)
        client.stub(options: options)
      end

      describe 'with mashify not specified' do
        it 'includes the Mashify middleware' do
          client.middleware.handlers.index(Restforce::Middleware::Mashify).
            should_not be_nil
        end
      end

      describe 'with mashify=true' do
        before(:each) do
          options.merge!(mashify: true)
        end

        it 'includes the Mashify middleware' do
          client.middleware.handlers.index(Restforce::Middleware::Mashify).
            should_not be_nil
        end
      end

      describe 'without mashify' do
        before(:each) do
          options.merge!(mashify: false)
        end

        it 'does not include the Mashify middleware' do
          client.middleware.handlers.index(Restforce::Middleware::Mashify).
            should be_nil
        end
      end
    end

    describe ":logger option" do
      let(:options) { { adapter: Faraday.default_adapter } }

      before(:each) do
        client.stub(:authentication_middleware)
        client.stub(:cache)
        client.stub(options: options)
        Restforce.stub(log?: true)
      end

      it "must always be used as the last handler" do
        client.middleware.handlers.reverse.index(Restforce::Middleware::Logger).
          should eq 0
      end
    end
  end

  describe '#adapter' do
    before do
      client.stub options: { adapter: :typhoeus }
    end

    its(:adapter) { should eq(:typhoeus) }
  end
end
