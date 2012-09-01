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
      its(:next_page)  { should be_nil }
      specify { subject.instance_variable_get(:@client).should eq client }

      describe 'each record' do
        it 'should be a Restforce::SObject' do
          records.each do |record|
            record.should be_a Restforce::SObject
          end
        end
      end
    end

    context 'with pagination' do
      let(:records) do
        described_class.new(JSON.parse(fixture('sobject/query_paginated_first_page_response')), client)
      end

      it               { should respond_to :each }
      its(:size)       { should eq 1 }
      its(:total_size) { should eq 2 }
      its(:next_page)  { should eq '/next/page/url' }
      specify { subject.instance_variable_get(:@client).should eq client }
    end
  end
end
