# frozen_string_literal: true

require 'spec_helper'

describe Restforce::Mash do
  describe '#build' do
    subject { described_class.build(input, nil) }

    context 'when array' do
      let(:input) { [{ foo: 'hello' }, { bar: 'world' }] }
      it { should(be_all { |obj| expect(obj).to be_a Restforce::Mash }) }
    end
  end

  describe '#klass' do
    subject { described_class.klass(input) }

    context 'when the hash has a "records" key' do
      let(:input) { { 'records' => nil } }
      it { should eq Restforce::Collection }
    end

    context 'when the hash has an "attributes" key' do
      let(:input) { { 'attributes' => { 'type' => 'Account' } } }
      it { should eq Restforce::SObject }

      context 'when the sobject type is an Attachment' do
        let(:input) { { 'attributes' => { 'type' => 'Attachment' } } }
        it { should eq Restforce::Attachment }
      end

      context 'when the sobject type is a Document' do
        let(:input) { { 'attributes' => { 'type' => 'Document' } } }
        it { should eq Restforce::Document }
      end

      context 'when the attributes value is nil' do
        let(:input) { { 'attributes' => nil } }
        it { should eq Restforce::SObject }
      end
    end

    context 'else' do
      let(:input) { {} }
      it { should eq Restforce::Mash }
    end
  end
end
