module EventMachine

  module Connectify
    def connectify(host, port, username=nil, password=nil, &blk)
      @connect_target_host = host
      @connect_target_port = port
      @connect_username = username
      @connect_password = password
      @connect_data = ''

      connect_hook
      connect_send_handshake

      @connect_deferrable = DefaultDeferrable.new
      @connect_deferrable.callback(&blk) if blk
      @connect_deferrable
    end

    def connect_hook
      extend CONNECT

      class << self
        alias receive_data connect_receive_data
      end
    end

    def connect_unhook
      class << self
        remove_method :receive_data
      end

      @connect_deferrable.succeed
    end

    def connect_receive_data(data)
      @connect_data << data
      connect_parse_response
    end
  end

end
