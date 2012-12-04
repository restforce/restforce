module Restforce
  class Client
    module Canvas

      # Public: Decodes a signed request received from Force.com Canvas.
      #
      # message - The POST message containing the signed request from Salesforce.
      #
      # Returns the Hash context if the message is valid.
      def decode_signed_request(message)
        raise 'client_secret not set' unless @options[:client_secret]
        Restforce.decode_signed_request(message, @options[:client_secret])
      end

    end
  end
end
