# frozen_string_literal: true

module Restforce
  # Authentication middleware used if username and password flow is used
  class Middleware::Authentication::Password < Restforce::Middleware::Authentication
    def params
      { grant_type: 'password',
        client_id: @options[:client_id],
        client_secret: @options[:client_secret],
        username: @options[:username],
        password: password }
    end

    def password
      "#{@options[:password]}#{@options[:security_token]}"
    end
  end
end
