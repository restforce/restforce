require 'spec_helper'

describe Restforce::Configuration do
  describe 'the configuration object' do
    subject { Restforce.configuration }

    it { should be_a Restforce::Configuration }

    context 'by default' do
      its(:api_version)  { should eq '24.0' }
      its(:host)         { should eq 'login.salesforce.com' }
      %w(username password security_token client_id client_secret
         oauth_token refresh_token instance_url).each do |attr|
        its(attr.to_sym) { should be_nil }
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
