# frozen_string_literal: true

require 'spec_helper'

describe Restforce::Middleware::InstanceURL do
  describe '.call' do
    subject { lambda { middleware.call(nil) } }

    context 'when the instance url is not set' do
      before do
        client.stub_chain :connection, url_prefix: URI.parse('http:/')
      end

      it { should raise_error Restforce::UnauthorizedError }
    end

    context 'when the instance url is set' do
      before do
        client.stub_chain :connection, url_prefix: URI.parse('http://foobar.com/')
        app.should_receive(:call).once
      end

      it { should_not raise_error }
    end
  end
end
