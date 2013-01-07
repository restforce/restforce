module Restforce
  class Client
    module Canvas

      def decode_signed_request(signed_request)
        raise 'client_secret not set' unless @options[:client_secret]
        SignedRequestd.decode(signed_request, @options[:client_secret])
      end

    end
  end
end
