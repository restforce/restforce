# frozen_string_literal: true

require 'spec_helper'

describe Restforce::Concerns::Caching do
  describe '.without_caching' do
    let(:options) { double('Options') }

    before do
      client.stub options: options
    end

    it 'runs the block with caching disabled' do
      options.should_receive(:[]=).with(:use_cache, false)
      options.should_receive(:delete).with(:use_cache)
      expect { |b| client.without_caching(&b) }.to yield_control
    end

    context 'when an exception is raised' do
      it 'ensures the :use_cache is deleted' do
        options.should_receive(:[]=).with(:use_cache, false)
        options.should_receive(:delete).with(:use_cache)
        expect {
          client.without_caching do
            raise 'Foo'
          end
        }.to raise_error 'Foo'
      end
    end
  end

  describe '.with_caching' do
    let(:options) { double('Options') }

    before do
      client.stub options: options
    end

    it 'runs the block with caching enabled' do
      options.should_receive(:[]=).with(:use_cache, true)
      options.should_receive(:[]=).with(:use_cache, false)
      expect { |b| client.with_caching(&b) }.to yield_control
    end

    context 'when an exception is raised' do
      it 'ensures the :use_cache is set to false' do
        options.should_receive(:[]=).with(:use_cache, true)
        options.should_receive(:[]=).with(:use_cache, false)
        expect {
          client.with_caching do
            raise 'Foo'
          end
        }.to raise_error 'Foo'
      end
    end
  end
end
