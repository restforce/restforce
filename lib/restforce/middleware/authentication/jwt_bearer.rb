require 'jwt'

module Restforce
  # Authentication middleware used if oauth_token and refresh_token are set
  class Middleware::Authentication::JWTBearer < Restforce::Middleware::Authentication
    def params
      { grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion: jwt_bearer_token }
    end

    def jwt_bearer_token
      JWT.encode claim_set, private_key, 'RS256'
    end

    def claim_set
      {
          iss: @options[:client_id],
          sub: @options[:username],
          aud: @options[:host],
          exp: Time.now.utc.to_i
      }
    end

    def private_key
      # check if the jwt_key is being stored as a file or string
      key_string = File.exist?(@options[:jwt_key]) ? File.read(@options[:jwt_key]) : @options[:jwt_key]
      OpenSSL::PKey::RSA.new key_string
    end
  end
end
