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
    subject { Restforce.log? }

    context 'by default' do
      it { should be_false }
    end
  end
end
