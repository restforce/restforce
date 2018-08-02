# frozen_string_literal: true

require 'spec_helper'

describe Restforce::Middleware::CustomHeaders do
  describe '.call' do
    subject { lambda { middleware.call(env) } }

    context 'when :request_headers are a Hash' do
      let(:options) { { request_headers: { 'x-test-header' => 'Test Value' } } }

      it { should change { env[:request_headers]['x-test-header'] }.to eq 'Test Value' }
    end

    context 'when :request_headers are not a Hash' do
      let(:options) { { request_headers: 'bad header' } }

      it { should_not(change { env[:request_headers] }) }
    end
  end
end
