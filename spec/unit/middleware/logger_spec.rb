# frozen_string_literal: true

require 'spec_helper'

describe Restforce::Middleware::Logger do
  let(:logger)     { double('logger') }
  let(:middleware) { described_class.new app, logger, options }

  describe '.call' do
    subject { lambda { middleware.call(env) } }

    before do
      app.should_receive(:call).once.and_return(app)
      app.should_receive(:on_complete).once { middleware.on_complete(env) }
      logger.should_receive(:debug).with('request')
      logger.should_receive(:debug).with('response')
    end

    it { should_not raise_error }
  end
end
