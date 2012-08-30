
module Restforce
  module Middleware

    # Authentication middleware used if oauth_token and refresh_token are set
    class OAuthRefreshAuthentication < Restforce::Middleware::Authentication

      def authenticate!
        response = connection.get '/services/oauth2/authorize', {
          :grant_type    => 'refresh_token',
          :client_id     => @options[:client_id],
          :client_secret => @options[:client_secret]
        }
        raise Restforce::AuthenticationError if response.status != 200
        @options[:instance_url] = response.body['instance_url']
        @options[:oauth_token]  = response.body['access_token']
      end
    
    end

  end
end
