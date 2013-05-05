require 'spec_helper'

shared_examples_for Restforce::Client do
  describe '.picklist_values' do
    requests 'sobjects/Account/describe',
      :fixture => 'sobject/sobject_describe_success_response'

    context 'when given a picklist field' do
      subject { client.picklist_values('Account', 'Picklist_Field') }
      it { should be_an Array }
      its(:length) { should eq 3 }
      it { should include_picklist_values ['one', 'two', 'three'] }
    end

    context 'when given a multipicklist field' do
      subject { client.picklist_values('Account', 'Picklist_Multiselect_Field') }
      it { should be_an Array }
      its(:length) { should eq 3 }
      it { should include_picklist_values ['four', 'five', 'six'] }
    end

    describe 'dependent picklists' do
      context 'when given a picklist field that has a dependency' do
        subject { client.picklist_values('Account', 'Dependent_Picklist_Field', :valid_for => 'one') }
        it { should be_an Array }
        its(:length) { should eq 2 }
        it { should include_picklist_values ['seven', 'eight'] }
        it { should_not include_picklist_values ['nine'] }
      end

      context 'when given a picklist field that does not have a dependency' do
        subject { client.picklist_values('Account', 'Picklist_Field', :valid_for => 'one') }
        it 'raises an exception' do
          expect { subject }.to raise_error(/Picklist_Field is not a dependent picklist/)
        end
      end
    end
  end

  describe '.faye', :eventmachine => true do
    subject { client.faye }

    context 'with missing instance url' do
      let(:instance_url) { nil }
      specify { expect { subject }.to raise_error RuntimeError, 'Instance URL missing. Call .authenticate! first.' }
    end

    context 'with oauth token and instance url' do
      let(:instance_url) { 'http://google.com' }
      let(:oauth_token) { 'bar' }
      specify { expect { subject }.to_not raise_error }
    end

    context 'when the connection goes down' do
      it 'should reauthenticate' do
        access_token = double('access token')
        access_token.stub(:access_token).and_return('token')
        client.should_receive(:authenticate!).and_return(access_token)
        client.faye.should_receive(:set_header).with('Authorization', "OAuth token")
        client.faye.trigger('transport:down')
      end
    end
  end

  describe '.subcribe', :eventmachine => true do
    context 'when given a single pushtopic' do
      it 'subscribes to the pushtopic' do
        client.faye.should_receive(:subscribe).with(['/topic/PushTopic'])
        client.subscribe('PushTopic')
      end
    end

    context 'when given an array of pushtopics' do
      it 'subscribes to each pushtopic' do
        client.faye.should_receive(:subscribe).with(['/topic/PushTopic1', '/topic/PushTopic2'])
        client.subscribe(['PushTopic1', 'PushTopic2'])
      end
    end
  end
end

describe Restforce::Client do
  describe 'with mashify' do
    it_behaves_like Restforce::Client
  end

  describe 'without mashify', :mashify => false do
    it_behaves_like Restforce::Client
  end
end
