require 'spec_helper'

describe Restforce::Middleware::Logger do
  let(:app)        { double('app')            }
  let(:env)        { { }  }
  let(:logger)     { double('logger') }
  let(:options)    { { :host => 'login.salesforce.com', :client_secret => 'foo', :password => 'bar' } }
  let(:middleware) { described_class.new app, logger, options }

  describe 'logging' do
    before do
      app.should_receive(:call).once.and_return(app)
      app.should_receive(:on_complete).once { middleware.on_complete(env) }
      logger.should_receive(:debug).with('request')
      logger.should_receive(:debug).with('response')
    end

    it 'logs the request and response' do
      middleware.call(env)
    end
  end
end
