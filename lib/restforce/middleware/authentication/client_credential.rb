# frozen_string_literal: true

module Restforce
  class Middleware
    class Authentication
      class ClientCredential < Restforce::Middleware::Authentication
        def params
          { grant_type: 'client_credentials',
            client_id: @options[:client_id],
            client_secret: @options[:client_secret] }
        end
      end
    end
  end
end
