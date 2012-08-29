require 'spec_helper'

describe Restforce::Client do
  include_context 'basic client'
  
  describe '.describe_sobjects' do
    subject { client.describe_sobjects }

    before do
      stub_api_request :sobjects, with: 'sobject/describe_sobjects_success_response'
    end

    it { should be_an Array }
  end

  describe '.list_sobjects' do
    subject { client.list_sobjects }

    before do
      stub_api_request :sobjects, with: 'sobject/describe_sobjects_success_response'
    end

    it { should be_an Array }
    it { should eq ['Account'] }
  end
end
