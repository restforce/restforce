# frozen_string_literal: true

module Restforce
  module Concerns
    module Streaming
      # Public: Subscribe to a PushTopic
      #
      # topics   - The name of the PushTopic channel(s) to subscribe to.
      # block    - A block to run when a new message is received.
      #
      # Returns a Faye::Subscription
      def legacy_subscribe(topics, options = {}, &block)
        topics = Array(topics).map { |channel| "/topic/#{channel}" }
        subscription(topics, options, &block)
      end
      alias subscribe legacy_subscribe

      # Public: Subscribe to one or more Streaming API channels
      #
      # channels - The name of the Streaming API (cometD) channel(s) to subscribe to.
      # block    - A block to run when a new message is received.
      #
      # Returns a Faye::Subscription
      def subscription(channels, options = {}, &block)
        one_or_more_channels = Array(channels)
        one_or_more_channels.each do |channel|
          replay_handlers[channel] = options[:replay]
        end
        faye.subscribe(one_or_more_channels, &block)
      end

      # Public: Faye client to use for subscribing to PushTopics
      def faye
        unless options[:instance_url]
          raise 'Instance URL missing. Call .authenticate! first.'
        end

        url = "#{options[:instance_url]}/cometd/#{options[:api_version]}"

        @faye ||= Faye::Client.new(url).tap do |client|
          client.set_header 'Authorization', "OAuth #{options[:oauth_token]}"

          client.bind 'transport:down' do
            Restforce.log "[COMETD DOWN]"
            client.set_header 'Authorization', "OAuth #{authenticate!.access_token}"
          end

          client.bind 'transport:up' do
            Restforce.log "[COMETD UP]"
          end

          client.add_extension ReplayExtension.new(replay_handlers)
        end
      end

      def replay_handlers
        @_replay_handlers ||= {}
      end

      class ReplayExtension
        def initialize(replay_handlers)
          @replay_handlers = replay_handlers
        end

        def incoming(message, callback)
          callback.call(message).tap do
            channel = message.fetch('channel')
            replay_id = message.fetch('data', {}).fetch('event', {})['replayId']

            handler = @replay_handlers[channel]
            if !replay_id.nil? && !handler.nil? && handler.respond_to?(:[]=)
              # remember the last replay_id for this channel
              handler[channel] = replay_id
            end
          end
        end

        def outgoing(message, callback)
          # Leave non-subscribe messages alone
          return callback.call(message) unless message['channel'] == '/meta/subscribe'

          channel = message['subscription']

          # Set the replay value for the channel
          message['ext'] ||= {}
          message['ext']['replay'] = {
            channel => replay_id(channel)
          }

          # Carry on and send the message to the server
          callback.call message
        end

        private

        def replay_id(channel)
          handler = @replay_handlers[channel]
          if handler.respond_to?(:[]) && !handler.is_a?(Integer)
            # Ask for the latest replayId for this channel
            handler[channel]
          else
            # Just pass it along
            handler
          end
        end
      end
    end
  end
end
