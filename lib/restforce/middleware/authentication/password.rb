module Restforce

  # Authentication middleware used if username and password flow is used
  class Middleware::Authentication::Password < Restforce::Middleware::Authentication

    def response
      @response ||= connection.post '/services/oauth2/token' do |req|
        req.body = URI.encode_www_form(
          :grant_type    => 'password',
          :client_id     => @options[:client_id],
          :client_secret => @options[:client_secret],
          :username      => @options[:username],
          :password      => password
        )
      end
    end

    def password
      "#{@options[:password]}#{@options[:security_token]}"
    end
  
  end

end
