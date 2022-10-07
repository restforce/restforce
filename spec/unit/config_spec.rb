# frozen_string_literal: true

require 'spec_helper'

describe Restforce do
  before do
    ENV['SALESFORCE_USERNAME']       = nil
    ENV['SALESFORCE_PASSWORD']       = nil
    ENV['SALESFORCE_SECURITY_TOKEN'] = nil
    ENV['SALESFORCE_CLIENT_ID']      = nil
    ENV['SALESFORCE_CLIENT_SECRET']  = nil
    ENV['SALESFORCE_API_VERSION']    = nil
  end

  after do
    Restforce.instance_variable_set :@configuration, nil
  end

  describe '#configuration' do
    subject { Restforce.configuration }

    it { should be_a Restforce::Configuration }

    context 'by default' do
      its(:api_version)            { should eq '26.0' }
      its(:host)                   { should eq 'login.salesforce.com' }
      its(:authentication_retries) { should eq 3 }
      its(:adapter)                { should eq Faraday.default_adapter }
      its(:ssl)                    { should eq({}) }
      %i[username password security_token client_id client_secret
         oauth_token refresh_token instance_url compress timeout
         proxy_uri authentication_callback mashify request_headers].each do |attr|
        its(attr) { should be_nil }
      end
    end

    context 'when environment variables are defined' do
      before do
        { 'SALESFORCE_USERNAME'       => 'foo',
          'SALESFORCE_PASSWORD'       => 'bar',
          'SALESFORCE_SECURITY_TOKEN' => 'foobar',
          'SALESFORCE_CLIENT_ID'      => 'client id',
          'SALESFORCE_CLIENT_SECRET'  => 'client secret',
          'SALESFORCE_PROXY_URI'      => 'proxy',
          'SALESFORCE_HOST'           => 'test.host.com',
          'SALESFORCE_API_VERSION'    => '37.0' }.
          each { |var, value| ENV.stub(:fetch).with(var, anything).and_return(value) }
      end

      its(:username)       { should eq 'foo' }
      its(:password)       { should eq 'bar' }
      its(:security_token) { should eq 'foobar' }
      its(:client_id)      { should eq 'client id' }
      its(:client_secret)  { should eq 'client secret' }
      its(:proxy_uri)      { should eq 'proxy' }
      its(:host)           { should eq 'test.host.com' }
      its(:api_version)    { should eq '37.0' }
    end
  end

  describe '#configure' do
    %i[username password security_token client_id client_secret compress
       timeout oauth_token refresh_token instance_url api_version host mashify
       authentication_retries proxy_uri authentication_callback ssl
       request_headers log_level logger].each do |attr|
      it "allows #{attr} to be set" do
        Restforce.configure do |config|
          config.send("#{attr}=", 'foobar')
        end
        expect(Restforce.configuration.send(attr)).to eq 'foobar'
      end
    end
  end

  describe '#log?' do
    subject { Restforce.log? }

    context 'by default' do
      it { should be false }
    end
  end

  describe '#log' do
    context 'with logging disabled' do
      before do
        Restforce.stub log?: false
      end

      it 'doesnt log anytning' do
        Restforce.configuration.logger.should_not_receive(:debug)
        Restforce.log 'foobar'
      end
    end

    context 'with logging enabled' do
      before { Restforce.stub(log?: true) }

      it 'logs something' do
        Restforce.configuration.logger.should_receive(:debug).with('foobar')
        Restforce.log 'foobar'
      end

      context "with a custom logger" do
        let(:fake_logger) { double(debug: true) }

        before do
          Restforce.configure do |config|
            config.logger = fake_logger
          end
        end

        it "logs using the provided logger" do
          fake_logger.should_receive(:debug).with('foobar')
          Restforce.log('foobar')
        end
      end

      context "with a custom log_level" do
        before do
          Restforce.configure do |config|
            config.log_level = :info
          end
        end

        it 'logs with the provided log_level' do
          Restforce.configuration.logger.should_receive(:info).with('foobar')
          Restforce.log 'foobar'
        end
      end
    end
  end

  describe '.new' do
    it 'calls its block' do
      checker = double(:block_checker)
      expect(checker).to receive(:check!).once
      Restforce.new do |builder|
        checker.check!
      end
    end
  end
end
