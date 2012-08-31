require 'spec_helper'

describe Restforce::Collection do
  describe '#new' do
    subject { records }

    context 'without pagination' do
      let(:records) do
        described_class.new(JSON.parse(fixture('sobject/query_success_response')))
      end

      it               { should respond_to :each }
      its(:size)       { should eq 1 }
      its(:total_size) { should eq 1 }
      its(:next_page)  { should be_nil }

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
        described_class.new(JSON.parse(fixture('sobject/query_paginated_first_page_response')))
      end

      it               { should respond_to :each }
      its(:size)       { should eq 1 }
      its(:total_size) { should eq 2 }
      its(:next_page)  { should eq '/next/page/url' }
    end
  end
end
