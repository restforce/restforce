module EventMachine
  module Socksify

    class SOCKSError < Exception
      def self.define(message)
        Class.new(self) do
          def initialize
            super(message)
          end
        end
      end

      ServerFailure           = define('general SOCKS server failure')
      NotAllowed              = define('connection not allowed by ruleset')
      NetworkUnreachable      = define('Network unreachable')
      HostUnreachable         = define('Host unreachable')
      ConnectionRefused       = define('Connection refused')
      TTLExpired              = define('TTL expired')
      CommandNotSupported     = define('Command not supported')
      AddressTypeNotSupported = define('Address type not supported')

      def self.for_response_code(code)
        case code.is_a?(String) ? code.ord : code
        when 1 then ServerFailure
        when 2 then NotAllowed
        when 3 then NetworkUnreachable
        when 4 then HostUnreachable
        when 5 then ConnectionRefused
        when 6 then TTLExpired
        when 7 then CommandNotSupported
        when 8 then AddressTypeNotSupported
        else self
        end
      end
    end

  end

  module Connectify
    class CONNECTError < Exception
    end
  end
end
