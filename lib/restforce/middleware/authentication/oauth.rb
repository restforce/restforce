module Restforce

  # Authentication middleware used if oauth_token and refresh_token are set
  class Middleware::Authentication::OAuth < Restforce::Middleware::Authentication

    def authenticate!
      response = connection.post '/services/oauth2/token' do |req|
        req.body = URI.encode_www_form(
          :grant_type    => 'refresh_token',
          :refresh_token => @options[:refresh_token],
          :client_id     => @options[:client_id],
          :client_secret => @options[:client_secret]
        )
      end
      raise Restforce::AuthenticationError if response.status != 200
      @options[:instance_url] = response.body['instance_url']
      @options[:oauth_token]  = response.body['access_token']
    end
  
  end

end
