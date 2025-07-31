module EventMachine

  module Socksify
    def socksify(host, port, username = nil, password = nil, version = 5, &blk)
      @socks_target_host = host
      @socks_target_port = port
      @socks_username = username
      @socks_password = password
      @socks_version = version
      @socks_data = ''

      socks_hook
      socks_send_handshake

      @socks_deferrable = DefaultDeferrable.new
      @socks_deferrable.callback(&blk) if blk
      @socks_deferrable
    end

    def socks_hook
      if @socks_version == 5
        extend SOCKS5
      else
        raise ArgumentError, 'SOCKS version unsupported'
      end

      class << self
        alias receive_data socks_receive_data
      end
    end

    def socks_unhook(ip = nil)
      class << self
        remove_method :receive_data
      end

      @socks_deferrable.succeed(ip)
    end

    def socks_receive_data(data)
      @socks_data << data
      socks_parse_response
    end
  end

end
