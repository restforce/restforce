require 'spec_helper'

RSpec::Matchers.define :have_client do |expected|
  match do |actual|
    actual.instance_variable_get(:@client) == expected
  end
end

describe Restforce::SObject do
  include_context 'basic client'

  let(:hash) { JSON.parse(fixture('sobject/query_success_response'))['records'].first }
  let(:sobject) do
    described_class.new(hash, client)
  end

  describe '#new' do
    context 'with valid options' do
      subject            { sobject }
      it                 { should be_a Restforce::SObject }
      its(:sobject_type) { should eq 'Whizbang' }
      its(:Text_Label)   { should eq 'Hi there!' }
      it { should have_client client }

      describe 'children' do
        subject { sobject.Whizbangs__r }

        it { should be_a Restforce::Collection }

        describe 'each child' do
          it 'should be a Restforce::SObject' do
            sobject.Whizbangs__r.each { |sobject| sobject.should be_a Restforce::SObject }
          end

          it 'should set the client' do
            sobject.Whizbangs__r.each { |sobject| sobject.should have_client client }
          end
        end
      end

      describe 'parent' do
        subject { sobject.ParentWhizbang__r }

        it { should be_a Restforce::SObject }
        its(:sobject_type) { should eq 'Whizbang' }
        its(:Name) { should eq 'Parent Whizbang' }
        it { should have_client client }
      end
    end
  end

  describe '.save' do
    subject { sobject.save }

    context 'when an Id was not queried' do
      specify { expect { subject }.to raise_error RuntimeError, 'You need to query the Id for the record in order to save.' }
    end

    context 'when an Id is present' do
      before do
        hash.merge!(Id: '001D000000INjVe')
      end

      before do
        @request = stub_api_request 'sobjects/Whizbang/001D000000INjVe', method: :patch
      end

      after do
        @request.should have_been_requested
      end

      specify { expect { subject }.to_not raise_error }
    end
  end

  describe '.destroy' do
    subject { sobject.destroy }

    context 'when an Id was not queried' do
      specify { expect { subject }.to raise_error RuntimeError, 'You need to query the Id for the record in order to save.' }
    end

    context 'when an Id is present' do
      before do
        hash.merge!(Id: '001D000000INjVe')
      end

      before do 
        @request = stub_api_request 'sobjects/Whizbang/001D000000INjVe', method: :delete
      end

      after do
        @request.should have_been_requested
      end

      specify { expect { subject }.to_not raise_error }
    end
  end
end
