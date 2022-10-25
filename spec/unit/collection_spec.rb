# frozen_string_literal: true

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
      its(:has_next_page?) { should be false }
      it                   { should have_client client }
      its(:page_size)      { should eq 1 }

      describe 'each record' do
        it { should(be_all { |record| expect(record).to be_a Restforce::SObject }) }
      end
    end

    context 'with pagination' do
      let(:first_page) do
        JSON.parse(fixture('sobject/query_paginated_first_page_response'))
      end

      let(:next_page) do
        JSON.parse(fixture('sobject/query_paginated_last_page_response'))
      end

      subject(:collection) { described_class.new(first_page, client) }

      it { should respond_to :each }
      it { should have_client client }

      context 'when only values from the first page are being requested' do
        before { client.should_receive(:get).never }

        its(:size)  { should eq 2 }
        its(:first) { should be_a Restforce::SObject }
        its(:current_page) { should be_a Array }
        its(:current_page) { should have(1).element }
        its(:page_size)    { should eq 1 }
      end

      context 'when all of the values are being requested' do
        before do
          client.stub(:get).
            and_return(double(body: Restforce::Collection.new(next_page, client)))
        end

        its(:pages) do
          should(be_all { |page| expect(page).to be_a Restforce::Collection })
        end

        its(:has_next_page?) { should be true }
        it { should(be_all { |record| expect(record).to be_a Restforce::SObject }) }
        its(:next_page)      { should be_a Restforce::Collection }
      end
    end
  end

  describe '#size' do
    subject(:size) do
      described_class.new(JSON.parse(fixture(sobject_fixture)), client).size
    end

    context 'when the query response contains a totalSize field' do
      let(:sobject_fixture) { 'sobject/query_success_response' }

      it { should eq 1 }
    end

    context 'when the query response contains a size field' do
      let(:sobject_fixture) { 'sobject/list_view_results_success_response' }

      it { should eq 1 }
    end
  end

  describe '#empty?' do
    subject(:empty?) do
      described_class.new(JSON.parse(fixture(sobject_fixture)), client).empty?
    end

    context 'with size 1' do
      let(:sobject_fixture) { 'sobject/query_success_response' }

      it { should be false }
    end

    context 'with size 0' do
      let(:sobject_fixture) { 'sobject/query_empty_response' }

      it { should be true }
    end
  end
end
