# frozen_string_literal: true

require 'spec_helper'

describe Restforce::Document do
  let(:client)   { double(Restforce::AbstractClient) }
  let(:body_url) { '/services/data/v26.0/sobjects/Document/00PG0000006Hll5MAC/Body' }
  let(:hash)     { { 'Id' => '1234', 'Body' => body_url } }
  let(:sobject)  { described_class.new(hash, client) }

  describe '.Body' do
    it 'requests the body' do
      client.should_receive(:get).with(body_url).
        and_return(double('response').as_null_object)
      sobject.Body
    end
  end
end
