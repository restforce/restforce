# frozen_string_literal: true

module Restforce
  module Concerns
    module Canvas
      def decode_signed_request(signed_request)
        raise 'client_secret not set.' unless options[:client_secret]

        SignedRequest.decode(signed_request, options[:client_secret])
      end
    end
  end
end
