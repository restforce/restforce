require 'spec_helper'

describe Restforce::Collection do
  let(:client) { double('client') }

  describe '#new' do
    subject { records }

    context 'without pagination' do
      let(:records) do
        described_class.new(JSON.parse(fixture('sobject/query_success_response')), client)
      end

      it               { should respond_to :each }
      its(:size)       { should eq 1 }
      its(:total_size) { should eq 1 }
      its(:next_page_url)  { should be_nil }
      specify { expect(subject.instance_variable_get(:@client)).to eq client }

      describe 'each record' do
        subject { records }
        it { should be_all { |record| expect(record).to be_a Restforce::SObject } }
      end
    end

    context 'with pagination' do
      let(:records) do
        described_class.new(JSON.parse(fixture('sobject/query_paginated_first_page_response')), client)
      end

      it               { should respond_to :each }
      its(:size)       { should eq 1 }
      its(:total_size) { should eq 2 }
      its(:next_page_url)  { should eq '/services/data/v24.0/query/01gD' }
      specify { expect(subject.instance_variable_get(:@client)).to eq client }

      describe '.next_page' do
        before do
          client.should_receive(:get).and_return(Faraday::Response.new(:body => Restforce::Collection.new({'records' => []}, client)))
        end

        subject { records.next_page }
        it { should be_a Restforce::Collection }
      end
    end
  end
end
