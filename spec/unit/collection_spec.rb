require 'spec_helper'

describe Restforce::Collection do
  let(:client) { double(Restforce::AbstractClient) }

  describe '#new' do
    context 'without pagination' do
      subject(:collection) do
        described_class.new(JSON.parse(fixture('sobject/query_success_response')), client)
      end

      it                   { should respond_to :each }
      its(:size)           { should eq 1 }
      its(:has_next_page?) { should be_false }
      it                   { should have_client client }

      describe 'each record' do
        it { should be_all { |record| expect(record).to be_a Restforce::SObject } }
      end
    end

    context 'with pagination' do
      let(:first_page)     { JSON.parse(fixture('sobject/query_paginated_first_page_response')) }
      let(:next_page)      { JSON.parse(fixture('sobject/query_paginated_last_page_response')) }
      subject(:collection) { described_class.new(first_page, client) }

      it { should respond_to :each }
      it { should have_client client }

      context 'when only values from the first page are being requested' do
        before { client.should_receive(:get).never }

        its(:size)  { should eq 2 }
        its(:first) { should be_a Restforce::SObject }
        its(:current_page) { should be_a Array }
        its(:current_page) { should have(1).element }
      end

      context 'when all of the values are being requested' do
        before do
          client.stub(:get).
            and_return(double(:body => Restforce::Collection.new(next_page, client)))
        end

        its(:pages)          { should be_all { |page| expect(page).to be_a Restforce::Collection } }
        its(:has_next_page?) { should be_true }
        it { should be_all   { |record| expect(record).to be_a Restforce::SObject } }
        its(:next_page)      { should be_a Restforce::Collection }
      end
    end
  end
end
