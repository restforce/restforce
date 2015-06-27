require 'spec_helper'

describe Restforce::Concerns::Streaming, event_machine: true do
  describe '.subscribe' do
    let(:channels)        { %w( channel1 channel2 ) }
    let(:topics)          { channels.map { |c| "/topic/#{c}" } }
    let(:subscribe_block) { lambda { 'subscribe' } }
    let(:faye_double)     { double('Faye') }

    it 'subscribes to the topics with faye' do
      faye_double.
        should_receive(:subscribe).
        with(topics, &subscribe_block)
      client.stub faye: faye_double

      client.subscribe(channels, &subscribe_block)
    end
  end

  describe '.faye' do
    subject { client.faye }

    context 'when authenticate! has already been called' do
      before do
        client.stub options: {
          instance_url: '/url',
          api_version: '30.0',
          oauth_token: 'secret'
        }
      end

      it 'connects to the streaming api' do
        client.stub authenticate!: OpenStruct.new(access_token: 'secret2')
        faye_double = double('Faye::Client')
        Faye::Client.
          should_receive(:new).
          with("/url/cometd/30.0").
          and_return(faye_double)
        faye_double.should_receive(:set_header).with('Authorization', 'OAuth secret')
        faye_double.should_receive(:set_header).with('Authorization', 'OAuth secret2')
        faye_double.should_receive(:bind).with('transport:down').and_yield
        faye_double.should_receive(:bind).with('transport:up').and_yield
        subject
      end
    end

    context 'when authenticate! has not been called' do
      it 'raises an error' do
        expect { subject }.to raise_error
      end
    end
  end
end
