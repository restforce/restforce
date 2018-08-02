# frozen_string_literal: true

require 'spec_helper'

describe Restforce::Concerns::Base do
  describe '#new' do
    context 'without options passed in' do
      it 'does not raise an exception' do
        expect {
          klass.new
        }.to_not raise_error
      end
    end

    context 'with a non-hash value' do
      it 'raises an ArgumentError exception' do
        expect {
          klass.new 'foo'
        }.to raise_error ArgumentError, 'Please specify a hash of options'
      end
    end

    it 'yields the builder to the block' do
      klass.any_instance.stub :builder
      expect { |b| klass.new(&b) }.to yield_control
    end
  end

  describe '.options' do
    subject { lambda { client.options } }
    it { should_not raise_error }
  end

  describe '.instance_url' do
    subject { client.instance_url }

    context 'when options[:instance_url] is unset' do
      it 'triggers an authentication' do
        client.should_receive :authenticate!
        subject
      end
    end

    context 'when options[:instance_url] is set' do
      before do
        client.stub options: { instance_url: 'foo' }
      end

      it { should eq 'foo' }
    end
  end
end
