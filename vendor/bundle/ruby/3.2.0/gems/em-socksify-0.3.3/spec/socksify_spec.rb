require 'helper'

describe EventMachine do

  # requires: ssh -D 8080 localhost
  it "should negotiate a socks connection" do

    class Handler < EM::Connection
      include EM::Socksify

      def connection_completed
        socksify('google.com', 80) do |ip|
          send_data "GET / HTTP/1.1\r\nConnection:close\r\nHost: google.com\r\n\r\n"
        end
      end

      def receive_data(data)
        @received ||= ''
        @received << data
      end

      def unbind
        @received.size.should > 0
        @received[0,4].should == 'HTTP'
        EM.stop
      end
    end

    EM.run do
      EventMachine.connect '127.0.0.1', 8080, Handler
    end
  end

  # requires squid running on localhost with default config
  it "should negotiate a connect connection" do

    class Handler < EM::Connection
      include EM::Connectify

      def connection_completed
        connectify('www.google.com', 443) do
          start_tls
          send_data "GET / HTTP/1.1\r\nConnection:close\r\nHost: www.google.com\r\n\r\n"
        end
      end

      def receive_data(data)
        @received ||= ''
        @received << data
      end

      def unbind
        @received.size.should > 0
        @received[0,4].should == 'HTTP'
        EM.stop
      end
    end

    EM::run do
      EventMachine.connect '127.0.0.1', 8081, Handler
    end

  end

end
