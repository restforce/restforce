# frozen_string_literal: true

require 'spec_helper'

shared_examples_for Restforce::Data::Client do
  describe '.picklist_values' do
    requests 'sobjects/Account/describe',
             fixture: 'sobject/sobject_describe_success_response'

    context 'when given a picklist field' do
      subject { client.picklist_values('Account', 'Picklist_Field') }
      it { should be_an Array }
      its(:length) { should eq 10 }
      it {
        should include_picklist_values %w[
          one two three control_four control_five
          control_six control_seven control_eight control_nine control_ten
        ]
      }
    end

    context 'when given a multipicklist field' do
      subject { client.picklist_values('Account', 'Picklist_Multiselect_Field') }
      it { should be_an Array }
      its(:length) { should eq 3 }
      it { should include_picklist_values %w[four five six] }
    end

    describe 'dependent picklists' do
      context 'when given a picklist field that has a dependency' do
        subject do
          client.picklist_values('Account',
                                 'Dependent_Picklist_Field',
                                 valid_for: 'one')
        end

        it { should be_an Array }
        its(:length) { should eq 2 }
        it { should include_picklist_values %w[seven eight] }
        it { should_not include_picklist_values ['nine'] }
      end

      context 'when given a picklist field that has a dependency index greater than 8' do
        subject do
          client.picklist_values('Account',
                                 'Dependent_Picklist_Field',
                                 valid_for: 'control_ten')
        end

        it { should be_an Array }
        its(:length) { should eq 1 }
        it { should include_picklist_values %w[ten] }
      end

      context 'when given a picklist field that does not have a dependency' do
        subject do
          client.picklist_values('Account', 'Picklist_Field', valid_for: 'one')
        end

        it 'raises an exception' do
          expect { subject }.to raise_error(/Picklist_Field is not a dependent picklist/)
        end
      end
    end
  end

  describe '.faye', event_machine: true do
    subject { client.faye }

    context 'with missing instance url' do
      let(:instance_url) { nil }

      it "raises an error" do
        expect { subject }.to raise_error RuntimeError, /Instance URL missing/
      end
    end

    context 'with oauth token and instance url' do
      let(:instance_url) { 'http://google.com' }
      let(:oauth_token) { 'bar' }

      it 'should not raise error' do
        client.stub(:authorize!)
        client.faye.stub(:set_header).with('Authorization', "OAuth token")
        expect { subject }.to_not raise_error
      end
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

  describe '.subscribe', event_machine: true do
    let(:faye_double)     { double('Faye') }

    context 'when given a single pushtopic' do
      it 'subscribes to the pushtopic' do
        faye_double.should_receive(:subscribe).with(['/topic/PushTopic'])
        client.stub faye: faye_double
        client.subscribe('PushTopic')
      end
    end

    context 'when given an array of pushtopics' do
      it 'subscribes to each pushtopic' do
        faye_double.should_receive(:subscribe).with(['/topic/PushTopic1',
                                                     '/topic/PushTopic2'])
        client.stub faye: faye_double
        client.subscribe(%w[PushTopic1 PushTopic2])
      end
    end
  end
end

describe Restforce::Data::Client do
  describe 'with mashify' do
    it_behaves_like Restforce::Client
  end

  describe 'without mashify', mashify: false do
    it_behaves_like Restforce::Client
  end
end
