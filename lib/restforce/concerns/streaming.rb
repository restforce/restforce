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
        @replay = options[:replay]
        @channels = Array(channels)
        faye.subscribe @channels.map { |channel| "/topic/#{channel}" }, &block
      end

      # Public: Faye client to use for subscribing to PushTopics
      def faye
        unless options[:instance_url]
          raise 'Instance URL missing. Call .authenticate! first.'
        end

        url = "#{options[:instance_url]}/cometd/#{options[:api_version]}"

        unless @faye
          @faye = Faye::Client.new(url).tap do |client|
            client.set_header 'Authorization', "OAuth #{options[:oauth_token]}"

            client.bind 'transport:down' do
              Restforce.log "[COMETD DOWN]"
              client.set_header 'Authorization', "OAuth #{authenticate!.access_token}"
            end

            client.bind 'transport:up' do
              Restforce.log "[COMETD UP]"
            end
          end

          if @replay
            @faye.add_extension ReplayExtension.new(channels: @channels, replay: @replay)
          end
        end

        @faye
      end

      class ReplayExtension
        def initialize(options)
          @channels = options[:channels]
          @replay = options[:replay]
        end

        def outgoing(message, callback)
          # Leave non-subscribe messages alone
          unless message['channel'] == '/meta/subscribe'
            return callback.call(message)
          end

          # Set the replay value for the each channel
          message['ext'] ||= {}
          message['ext']['replay'] = {}
          @channels.each do |channel|
            message['ext']['replay']["/topic/#{channel}"] = @replay
          end

          # Carry on and send the message to the server
          callback.call message
        end
      end
    end
  end
end
