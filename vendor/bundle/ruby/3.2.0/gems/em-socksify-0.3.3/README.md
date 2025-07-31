# Transparent proxy support for any EventMachine protocol

Dealing with SOCKS and HTTP proxies is a pain. EM-Socksify provides a simple ship to setup and negotiation a SOCKS / HTTP connection for any EventMachine protocol.

### Example: Routing HTTP request via SOCKS5 proxy

```ruby
class Handler < EM::Connection
  include EM::Socksify

  def connection_completed
    socksify('google.ca', 80) do
      send_data "GET / HTTP/1.1\r\nConnection:close\r\nHost: google.ca\r\n\r\n"
    end
  end

  def receive_data(data)
    p data
  end
end

EM.run do
  EventMachine.connect SOCKS_HOST, SOCKS_PORT, Handler
end
```

What's happening here? First, we open a raw TCP connection to the SOCKS proxy. Once the TCP connection is established, EventMachine calls the **connection_completed** method in our handler, at which point we call the helper method (**socksify**) with the actual destination and host and port (address that we actually want to get to), and the module does the rest.

socksify temporarily intercepts your receive_data callbacks, negotiates the SOCKS connection (version, authentication, etc), and then once all of that is done, returns control back to your code.

For SOCKS proxies which require authentication, use:

```ruby
socksify(destination_host, destination_port, username, password, version)
```

### Example: Routing HTTPS request via a squid CONNECT proxy

```ruby
class Handler < EM::Connection
  include EM::Connectify

  def connection_completed
    connectify('www.google.ca', 443) do
      start_tls
      send_data "GET / HTTP/1.1\r\nConnection:close\r\nHost: www.google.ca\r\n\r\n"
    end
  end

  def receive_data(data)
    p data
  end
end

EM.run do
  EventMachine.connect PROXY_HOST, PROXY_PORT, Handler
end
```

For CONNECT proxies which require authentication, use:

```ruby
connectify(destination_host, destination_port, username, password)
```

### Wishlist

- IPV6 support
- SOCKS4 support

### Resources

- [SOCKS on Wikipedia](http://en.wikipedia.org/wiki/SOCKS)
- [Socksify-Ruby](https://github.com/astro/socksify-ruby) for regular Ruby TCPSocket
- [HTTP Connect Tunneling](http://en.wikipedia.org/wiki/HTTP_tunnel#HTTP_CONNECT_Tunneling)

### Contributors

- [Ilya Grigorik](https://github.com/igrigorik)
- [Conrad Irwin](https://github.com/ConradIrwin)

### License

(The MIT License)
