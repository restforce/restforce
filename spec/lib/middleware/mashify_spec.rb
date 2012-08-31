require 'spec_helper'

describe Restforce::Middleware::Mashify do
  let(:app)        { double('app')            }
  let(:env)        { { }  }
  let(:options)    { { } }
  let(:middleware) { described_class.new app, nil, options }
end
