# frozen_string_literal: true

require 'spec_helper'

describe Restforce::Concerns::Streaming, event_machine: true do
  describe '.subscribe' do
    let(:channels) do
      ['/topic/topic1', '/event/MyCustomEvent__e', '/data/ChangeEvents']
    end
    let(:subscribe_block) { lambda { 'subscribe' } }
    let(:faye_double)     { double('Faye') }

    it 'subscribes to the topics with faye' do
      faye_double.
        should_receive(:subscribe).
        with(channels)
      client.stub faye: faye_double

      client.subscription(channels)
    end

    context "replay_handlers" do
      before {
        faye_double.should_receive(:subscribe).at_least(1)
        client.stub faye: faye_double
      }

      it 'registers nil handlers when no replay option is given' do
        client.subscription(channels, &subscribe_block)
        client.replay_handlers.should eq(
          '/topic/topic1' => nil,
          '/event/MyCustomEvent__e' => nil,
          '/data/ChangeEvents' => nil
        )
      end

      it 'registers a replay_handler for each channel given' do
        client.subscription(channels, replay: -2, &subscribe_block)
        client.replay_handlers.should eq(
          '/topic/topic1' => -2,
          '/event/MyCustomEvent__e' => -2,
          '/data/ChangeEvents' => -2
        )
      end

      it 'replaces earlier handlers in subsequent calls' do
        client.subscription(
          ['/topic/channel1', '/topic/channel2'],
          replay: 2,
          &subscribe_block
        )
        client.subscription(
          ['/topic/channel2', '/topic/channel3'],
          replay: 3,
          &subscribe_block
        )

        client.replay_handlers.should eq(
          '/topic/channel1' => 2,
          '/topic/channel2' => 3,
          '/topic/channel3' => 3
        )
      end

      context 'backwards compatibility' do
        it 'it assumes channels are push topics' do
          client.subscribe(%w[channel1 channel2], replay: -2, &subscribe_block)
          client.replay_handlers.should eq(
            '/topic/channel1' => -2,
            '/topic/channel2' => -2
          )
        end
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
        client.stub authenticate!: double(access_token: 'secret2')
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

  describe "ReplayExtension" do
    let(:handlers) { {} }
    let(:extension) { Restforce::Concerns::Streaming::ReplayExtension.new(handlers) }

    it 'sends nil without a specified handler' do
      output = subscribe(extension, to: "/topic/channel1")
      read_replay(output).should eq('/topic/channel1' => nil)
    end

    it 'with a scalar replay id' do
      handlers['/topic/channel1'] = -2
      output = subscribe(extension, to: "/topic/channel1")
      read_replay(output).should eq('/topic/channel1' => -2)
    end

    it 'with a hash' do
      hash_handler = { '/topic/channel1' => -1, '/topic/channel2' => -2 }

      handlers['/topic/channel1'] = hash_handler
      handlers['/topic/channel2'] = hash_handler

      output = subscribe(extension, to: "/topic/channel1")
      read_replay(output).should eq('/topic/channel1' => -1)

      output = subscribe(extension, to: "/topic/channel2")
      read_replay(output).should eq('/topic/channel2' => -2)
    end

    it 'with an object' do
      custom_handler = double('custom_handler')
      custom_handler.should_receive(:[]).and_return(123)
      handlers['/topic/channel1'] = custom_handler

      output = subscribe(extension, to: "/topic/channel1")
      read_replay(output).should eq('/topic/channel1' => 123)
    end

    it 'remembers the last replayId' do
      handler = { '/topic/channel1' => 41 }
      handlers['/topic/channel1'] = handler
      message = {
        'channel' => '/topic/channel1',
        'data' => {
          'event' => { 'replayId' => 42 }
        }
      }

      extension.incoming(message, ->(m) {})
      handler.should eq('/topic/channel1' => 42)
    end

    it 'when an incoming message has no replayId' do
      handler = { '/topic/channel1' => 41 }
      handlers['/topic/channel1'] = handler

      message = {
        'channel' => '/topic/channel1',
        'data' => {}
      }

      extension.incoming(message, ->(m) {})
      handler.should eq('/topic/channel1' => 41)
    end

    private

    def subscribe(extension, options = {})
      output = nil
      message = {
        'channel' => '/meta/subscribe',
        'subscription' => options[:to]
      }
      extension.outgoing(message, ->(m) {
        output = m
      })
      output
    end

    def read_replay(message)
      message.fetch('ext', {})['replay']
    end
  end
end
