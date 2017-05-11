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
          exp: Time.now.utc.to_i.to_s
      }
    end

    def private_key
      OpenSSL::PKey::RSA.new File.read(@options[:jwt_key])
    end
  end
end
