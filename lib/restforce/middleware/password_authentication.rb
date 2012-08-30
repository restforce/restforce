module Restforce
  module Middleware

    # Authentication middleware used if username and password flow is used
    class PasswordAuthentication < Restforce::Middleware::Authentication

      def authenticate!
        response = connection.get '/services/oauth2/authorize', {
          :grant_type    => 'password',
          :client_id     => @options[:client_id],
          :client_secret => @options[:client_secret],
          :username      => @options[:username],
          :password      => password
        }
        raise Restforce::AuthenticationError if response.status != 200
        @options[:instance_url] = response.body['instance_url']
        @options[:oauth_token]  = response.body['access_token']
      end

      def password
        "#{@options[:password]}#{@options[:security_token]}"
      end
    
    end

  end
end
