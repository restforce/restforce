# frozen_string_literal: true

module Restforce
  module Concerns
    module Streaming
      # Public: Subscribe to a PushTopic
      #
      # channels - The name of the PushTopic channel(s) to subscribe to.
      # block    - A block to run when a new message is received.
      #
      # Returns a Faye::Subscription
      def subscribe(channels, options = {}, &block)
        Array(channels).each { |channel| replay_handlers[channel] = options[:replay] }
        faye.subscribe Array(channels).map { |channel| "/topic/#{channel}" }, &block
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
            channel = message.fetch('channel').gsub('/topic/', '')
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
          unless message['channel'] == '/meta/subscribe'
            return callback.call(message)
          end

          channel = message['subscription'].gsub('/topic/', '')

          # Set the replay value for the channel
          message['ext'] ||= {}
          message['ext']['replay'] = {
            "/topic/#{channel}" => replay_id(channel)
          }

          # Carry on and send the message to the server
          callback.call message
        end

        private

        def replay_id(channel)
          handler = @replay_handlers[channel]
          case
          when handler.is_a?(Integer)
            handler # treat it as a scalar
          when handler.respond_to?(:[])
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
