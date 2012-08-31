require 'spec_helper'

describe Restforce::Configuration do
  after do
    Restforce.instance_variable_set :@configuration, nil
  end

  describe 'the configuration object' do
    subject { Restforce.configuration }

    it { should be_a Restforce::Configuration }

    context 'by default' do
      its(:api_version)  { should eq '24.0' }
      its(:host)         { should eq 'login.salesforce.com' }
      [:username, :password, :security_token, :client_id, :client_secret,
       :oauth_token, :refresh_token, :instance_url].each do |attr|
        its(attr) { should be_nil }
      end
    end
  end

  describe '#configure' do
    [:username, :password, :security_token, :client_id, :client_secret,
     :oauth_token, :refresh_token, :instance_url, :api_version, :host].each do |attr|
      it "allows #{attr} to be set" do
        Restforce.configure do |config|
          config.send("#{attr}=", 'foobar')
        end
        Restforce.configuration.send(attr).should eq 'foobar'
      end
    end
  end

  describe 'logging' do
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
end
