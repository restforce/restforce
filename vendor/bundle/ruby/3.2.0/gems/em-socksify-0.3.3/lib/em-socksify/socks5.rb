module EventMachine
  module Socksify

    module SOCKS5
      def socks_send_handshake
        # Method Negotiation as described on
        # http://www.faqs.org/rfcs/rfc1928.html Section 3
        @socks_state = :method_negotiation

        socks_methods.tap do |methods|
          send_data [5, methods.size].pack('CC') + methods.pack('C*')
        end
      end

      def socks_send_connect_request
        @socks_state = :connecting

        send_data [5, 1, 0].pack('CCC')

        if matches = @socks_target_host.match(/^(\d+)\.(\d+)\.(\d+)\.(\d+)$/)
          send_data "\x01" + matches.to_a[1 .. -1].map { |s| s.to_i }.pack('CCCC')

        elsif @socks_target_host =~ /^[:0-9a-f]+$/
          raise SOCKSError, 'TCP/IPv6 over SOCKS is not yet supported (inet_pton missing in Ruby & not supported by Tor)'

        else
          send_data [3, @socks_target_host.size, @socks_target_host].pack('CCA*')
        end

        send_data [@socks_target_port].pack('n')
      end

      def socks_send_authentication
        @socks_state = :authenticating

        send_data [5,
                   @socks_username.length, @socks_username,
                   @socks_password.length, @socks_password
                   ].pack('CCA*CA*')
      end

      private

        # parses socks 5 server responses as specified
        # on http://www.faqs.org/rfcs/rfc1928.html
        def socks_parse_response
          case @socks_state
          when :method_negotiation
            return unless @socks_data.size >= 2

            _, method = @socks_data.slice!(0, 2).unpack('CC')

            if socks_methods.include?(method)
              case method
              when 0 then socks_send_connect_request
              when 2 then socks_send_authentication
              end
            else
              raise SOCKSError, 'proxy did not accept method'
            end

          when :authenticating
            return unless @socks_data.size >= 2

            socks_version, status_code = @socks_data.slice!(0, 2).unpack('CC')

            raise SOCKSError, "SOCKS version 5 not supported" unless socks_version == 5
            raise SOCKSError, 'access denied by proxy'        unless status_code == 0

            socks_send_connect_request

          when :connecting
            return unless @socks_data.size >= 2

            socks_version, status_code = @socks_data.slice(0, 2).unpack('CC')

            raise SOCKSError, "SOCKS version #{socks_version} is not 5" unless socks_version == 5
            raise SOCKSError.for_response_code(status_code)             unless status_code == 0

            min_size = @socks_data[3].ord == 3 ? 5 : 4

            return unless @socks_data.size >= min_size

            size = case @socks_data[3].ord
            when 1 then 4
            when 3 then @socks_data[4].ord
            when 4 then 16
            else raise SOCKSError.for_response_code(@socks_data[3])
            end

            return unless @socks_data.size >= (min_size + size)

            bind_addr = @socks_data.slice(min_size, size)

            ip = case @socks_data[3].ord
            when 1 then bind_addr.bytes.to_a.join('.')
            when 3 then bind_addr
            when 4 then # TODO: ???
            end

            socks_unhook(ip)
          end
        rescue Exception => e
          @socks_deferrable.fail(e)
        end

        def socks_methods
          methods = []
          methods << 2 if !@socks_username.nil? # 2 => Username/Password Authentication
          methods << 0 # 0 => No Authentication Required

          methods
        end
    end

  end
end
