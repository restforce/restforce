module Restforce
  module Middleware
    class Authentication < Faraday::Middleware

      def initialize(app, options = {})
        @app = app
        @options = options
      end

      def call(env)
        begin
          @app.call(env)
        rescue Faraday::Error::ClientError
          authenticate!
          @app.call(env)
        end
      end

      def authenticate!
        if username_password_flow?
          response = connection.get '/services/oauth2/authorize', {
            :grant_type => 'password',
            :client_id => @options[:client_id],
            :client_secret => @options[:client_secret],
            :username => @options[:username],
            :password => @options[:password]
          }
          raise Restforce::AuthenticationError if response.status != 200
          @options[:instance_url] = response.body['instance_url']
          @options[:oauth_token] = response.body['access_token']
        elsif web_server_flow?
        end
      end

      def connection
        @connection ||= Faraday.new(:url => "https://#{@options[:host]}") do |builder|
          builder.request :json
          builder.response :json
          builder.adapter Faraday.default_adapter
        end
        @connection
      end

      def username_password_flow?
        @options[:username] && @options[:password] && @options[:client_id] && @options[:client_secret]
      end

      def web_server_flow?
        @options[:oauth_token] && @options[:refresh_token]
      end
    
    end
  end
end
