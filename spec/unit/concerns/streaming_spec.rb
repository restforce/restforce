# frozen_string_literal: true

require 'spec_helper'

describe Restforce::Concerns::Streaming, event_machine: true do
  describe '.subscribe' do
    let(:channels)        { %w[channel1 channel2] }
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

    context "replay_handlers" do
      before {
        faye_double.should_receive(:subscribe).at_least(1)
        client.stub faye: faye_double
      }

      it 'registers nil handlers when no replay option is given' do
        client.subscribe(channels, &subscribe_block)
        client.replay_handlers.should eq('channel1' => nil, 'channel2' => nil)
      end

      it 'registers a replay_handler for each channel given' do
        client.subscribe(channels, replay: -2, &subscribe_block)
        client.replay_handlers.should eq('channel1' => -2, 'channel2' => -2)
      end

      it 'replaces earlier handlers in subsequent calls' do
        client.subscribe(%w(channel1 channel2), replay: 2, &subscribe_block)
        client.subscribe(%w(channel2 channel3), replay: 3, &subscribe_block)
        client.replay_handlers.should eq(
          'channel1' => 2,
          'channel2' => 3,
          'channel3' => 3
        )
      end
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
        faye_double.should_receive(:add_extension).with \
          kind_of(Restforce::Concerns::Streaming::ReplayExtension)
        subject
      end
    end

    context 'when authenticate! has not been called' do
      it 'raises an error' do
        expect { subject }.to raise_error
      end
    end
  end

  describe Restforce::Concerns::Streaming::ReplayExtension do
    let(:handlers) { {} }
    let(:extension) { Restforce::Concerns::Streaming::ReplayExtension.new(handlers) }

    it 'sends nil without a specified handler' do
      output = subscribe(extension, to: "channel1")
      read_replay(output).should eq('/topic/channel1' => nil)
    end

    it 'with a scalar replay id' do
      handlers['channel1'] = -2
      output = subscribe(extension, to: "channel1")
      read_replay(output).should eq('/topic/channel1' => -2)
    end

    it 'with a hash' do
      hash_handler = { 'channel1' => -1, 'channel2' => -2 }

      handlers['channel1'] = hash_handler
      handlers['channel2'] = hash_handler

      output = subscribe(extension, to: "channel1")
      read_replay(output).should eq('/topic/channel1' => -1)

      output = subscribe(extension, to: "channel2")
      read_replay(output).should eq('/topic/channel2' => -2)
    end

    it 'with an object' do
      custom_handler = double('custom_handler')
      custom_handler.should_receive(:[]).and_return(123)
      handlers['channel1'] = custom_handler

      output = subscribe(extension, to: "channel1")
      read_replay(output).should eq('/topic/channel1' => 123)
    end

    it 'remembers the last replayId' do
      handler = { 'channel1' => 41 }
      handlers['channel1'] = handler
      message = {
        'channel' => '/topic/channel1',
        'data' => {
          'event' => { 'replayId' => 42 }
        }
      }

      extension.incoming(message, -> m {})
      handler.should eq('channel1' => 42)
    end

    it 'when an incoming message has no replayId' do
      handler = { 'channel1' => 41 }
      handlers['channel1'] = handler

      message = {
        'channel' => '/topic/channel1',
        'data' => {}
      }

      extension.incoming(message, -> m {})
      handler.should eq('channel1' => 41)
    end

    private

    def subscribe(extension, options = {})
      output = nil
      message = {
        'channel' => '/meta/subscribe',
        'subscription' => "/topic/#{options[:to]}"
      }
      extension.outgoing(message, -> m {
        output = m
      })
      output
    end

    def read_replay(message)
      message.fetch('ext', {})['replay']
    end
  end
end
