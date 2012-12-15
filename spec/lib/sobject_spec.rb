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
          subject { sobject.Whizbangs__r }
          it { should be_all { |sobject| expect(sobject).to be_a Restforce::SObject } }
          it { should be_all { |sobject| expect(sobject).to have_client client } }
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
      specify { expect { subject }.to raise_error RuntimeError, 'You need to query the Id for the record first.' }
    end

    context 'when an Id is present' do
      requests 'sobjects/Whizbang/001D000000INjVe',
        :method => :patch,
        :with_body => "{\"Checkbox_Label\":false,\"Text_Label\":\"Hi there!\",\"Date_Label\":\"2010-01-01\"," +
        "\"DateTime_Label\":\"2011-07-07T00:37:00.000+0000\",\"Picklist_Multiselect_Label\":\"four;six\"}"

      before do
        hash.merge!(:Id => '001D000000INjVe')
      end

      specify { expect { subject }.to_not raise_error }
    end
  end

  describe '.save!' do
    subject { sobject.save! }

    context 'when an exception is raised' do
      requests 'sobjects/Whizbang/001D000000INjVe',
        :fixture => 'sobject/delete_error_response',
        :method => :patch,
        :status => 404

      before do
        hash.merge!(:Id => '001D000000INjVe')
      end

      specify { expect { subject }.to raise_error Faraday::Error::ResourceNotFound }
    end
  end

  describe '.destroy' do
    subject { sobject.destroy }

    context 'when an Id was not queried' do
      specify { expect { subject }.to raise_error RuntimeError, 'You need to query the Id for the record first.' }
    end

    context 'when an Id is present' do
      requests 'sobjects/Whizbang/001D000000INjVe', :method => :delete

      before do 
        hash.merge!(:Id => '001D000000INjVe')
      end

      specify { expect { subject }.to_not raise_error }
    end
  end

  describe '.destroy!' do
    subject { sobject.destroy! }

    context 'when an exception is raised' do
      requests 'sobjects/Whizbang/001D000000INjVe',
        :fixture => 'sobject/delete_error_response',
        :method => :delete,
        :status => 404

      before do
        hash.merge!(:Id => '001D000000INjVe')
      end

      specify { expect { subject }.to raise_error Faraday::Error::ResourceNotFound }
    end
  end

  describe '.describe' do
    requests 'sobjects/Whizbang/describe',
      :fixture => 'sobject/sobject_describe_success_response'

    subject { sobject.describe }
    it { should be_a Hash }
  end
end
