require 'spec_helper'

describe Restforce do
  before do
    ENV['SALESFORCE_USERNAME']       = nil
    ENV['SALESFORCE_PASSWORD']       = nil
    ENV['SALESFORCE_SECURITY_TOKEN'] = nil
    ENV['SALESFORCE_CLIENT_ID']      = nil
    ENV['SALESFORCE_CLIENT_SECRET']  = nil
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
      [:username, :password, :security_token, :client_id, :client_secret,
       :oauth_token, :refresh_token, :instance_url, :compress].each do |attr|
        its(attr) { should be_nil }
      end
    end

    context 'when environment variables are defined' do
      before do
        ENV['SALESFORCE_USERNAME']       = 'foo'
        ENV['SALESFORCE_PASSWORD']       = 'bar'
        ENV['SALESFORCE_SECURITY_TOKEN'] = 'foobar'
        ENV['SALESFORCE_CLIENT_ID']      = 'client id'
        ENV['SALESFORCE_CLIENT_SECRET']  = 'client secret'
      end

      after do
        ENV.delete('SALESFORCE_USERNAME')
        ENV.delete('SALESFORCE_PASSWORD')
        ENV.delete('SALESFORCE_SECURITY_TOKEN')
        ENV.delete('SALESFORCE_CLIENT_ID')
        ENV.delete('SALESFORCE_CLIENT_SECRET')
      end

      its(:username)       { should eq 'foo' }
      its(:password)       { should eq 'bar'}
      its(:security_token) { should eq 'foobar' }
      its(:client_id)      { should eq 'client id' }
      its(:client_secret)  { should eq 'client secret' }
    end
  end

  describe '#configure' do
    [:username, :password, :security_token, :client_id, :client_secret, :compress,
     :oauth_token, :refresh_token, :instance_url, :api_version, :host, :authentication_retries].each do |attr|
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
      it { should be_false }
    end
  end

  describe '#log' do
    after do
      Restforce.log = false
    end

    context 'with logging disabled' do
      before do
        Restforce.log = false
        Restforce.configuration.logger.should_not_receive(:debug)
      end

      it 'doesnt log anytning' do
        Restforce.log 'foobar'
      end
    end
    
    context 'with logging enabled' do
      before do
        Restforce.log = true
        Restforce.configuration.logger.should_receive(:debug).with('foobar')
      end

      it 'logs something' do
        Restforce.log 'foobar'
      end
    end
  end
end
