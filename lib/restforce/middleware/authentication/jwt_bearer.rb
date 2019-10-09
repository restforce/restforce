# frozen_string_literal: true

require 'jwt'

module Restforce
  class Middleware
    class Authentication
      class JWTBearer < Restforce::Middleware::Authentication
        def params
          {
            grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
            assertion: jwt_bearer_token
          }
        end

        private

        def jwt_bearer_token
          JWT.encode claim_set, private_key, 'RS256'
        end

        def claim_set
          {
            iss: @options[:client_id],
            sub: @options[:username],
            aud: @options[:host],
            iat: Time.now.utc.to_i,
            exp: Time.now.utc.to_i + 180
          }
        end

        def private_key
          OpenSSL::PKey::RSA.new(@options[:jwt_key])
        end
      end
    end
  end
end
