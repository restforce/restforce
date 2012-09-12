module Restforce

  # Authentication middleware used if username and password flow is used
  class Middleware::Authentication::Password < Restforce::Middleware::Authentication

    def authenticate!
      response = connection.post '/services/oauth2/token' do |req|
        req.body = URI.encode_www_form(
          :grant_type    => 'password',
          :client_id     => @options[:client_id],
          :client_secret => @options[:client_secret],
          :username      => @options[:username],
          :password      => password
        )
      end
      raise Restforce::AuthenticationError, error_message(response) if response.status != 200
      @options[:instance_url] = response.body['instance_url']
      @options[:oauth_token]  = response.body['access_token']
    end

    def password
      "#{@options[:password]}#{@options[:security_token]}"
    end
  
  end

end
