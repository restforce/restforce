require 'spec_helper'

describe Restforce::Collection do
  let(:client) { double('client') }

  describe '#new' do
    subject { records }

    context 'without pagination' do
      let(:records) do
        described_class.new(JSON.parse(fixture('sobject/query_success_response')), client)
      end

      it         { should respond_to :each }
      its(:size) { should eq 1 }
      specify { expect(subject.instance_variable_get(:@client)).to eq client }

      describe 'each record' do
        subject { records }
        it { should be_all { |record| expect(record).to be_a Restforce::SObject } }
      end
    end

    context 'with pagination' do
      let(:first_page) { JSON.parse(fixture('sobject/query_paginated_first_page_response')) }
      let(:next_page) { JSON.parse(fixture('sobject/query_paginated_last_page_response')) }
      let(:response) { mock(:body => next_page) }
      let(:records) { described_class.new(first_page, client) }

      it { should respond_to :each }
      specify { expect(subject.instance_variable_get(:@client)).to eq client }

      context 'when only values from the first page are being requested' do
        before { client.should_not_receive(:get) }

        its(:size) { should eq 2 }
        its(:first) { should be_an_instance_of Restforce::SObject }
      end

      context 'when all of the values are being requested' do
        before do
          response.should_receive(:[]).with('nextRecordsUrl').and_return(nil)
          client.should_receive(:get).with(first_page['nextRecordsUrl']).and_return(response)
        end

        it { should be_all { |record| expect(record).to be_a Restforce::SObject } }
      end
    end
  end
end
