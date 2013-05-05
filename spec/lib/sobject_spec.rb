require 'spec_helper'

describe Restforce::SObject do
  let(:client)  { double('Client') }
  let(:hash)    { JSON.parse(fixture('sobject/query_success_response'))['records'].first }
  let(:sobject) { described_class.new(hash, client) }

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
      it 'delegates to client.update' do
        hash.merge!(:Id => '001D000000INjVe')
        client.should_receive(:update)
        subject
      end
    end
  end

  describe '.save!' do
    subject { sobject.save! }

    it 'delegates to client.update!' do
      hash.merge!(:Id => '001D000000INjVe')
      client.should_receive(:update!)
      subject
    end
  end

  describe '.destroy' do
    subject { sobject.destroy }

    context 'when an Id was not queried' do
      specify { expect { subject }.to raise_error RuntimeError, 'You need to query the Id for the record first.' }
    end

    context 'when an Id is present' do
      it 'delegates to client.destroy' do
        hash.merge!(:Id => '001D000000INjVe')
        client.should_receive(:destroy)
        subject
      end
    end
  end

  describe '.destroy!' do
    subject { sobject.destroy! }

    context 'when an exception is raised' do
      it 'delegates to client.destroy!' do
        hash.merge!(:Id => '001D000000INjVe')
        client.should_receive(:destroy!)
        subject
      end
    end
  end

  describe '.describe' do
    subject { sobject.describe }

    it 'delegates to client.describe' do
      client.should_receive(:describe).with('Whizbang')
      subject
    end
  end
end
