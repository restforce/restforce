module EventMachine
  module Connectify
    module CONNECT
      def connect_send_handshake
        header =  "CONNECT #{@connect_target_host}:#{@connect_target_port} HTTP/1.0\r\n"
        if @connect_username || @connect_password
          encoded_credentials = Base64.strict_encode64([@connect_username, @connect_password].join(":"))
          header << "Proxy-Authorization: Basic #{encoded_credentials}\r\n"
        end

        header << "\r\n"
        send_data(header)
      end

      private

      def connect_parse_response
        unless @connect_data =~ %r{\AHTTP/1\.[01] 200 .*\r\n\r\n}m
          raise CONNECTError.new, "Unexpected response: #{@connect_data}"
        end

        connect_unhook
      rescue => e
        @connect_deferrable.fail e
      end
    end
  end
end
