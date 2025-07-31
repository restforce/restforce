require 'eventmachine'
require 'base64'

require 'em-socksify/socksify'
require 'em-socksify/errors'
require 'em-socksify/socks5'
require 'em-socksify/connectify'
require 'em-socksify/connect'

# Backport from ruby-1.9 to ruby-1.8 (which doesn't support pack('m0') either)
unless Base64.respond_to?(:strict_encode64)
  def Base64.strict_encode64(str)
    Base64.encode64(str).gsub("\n", "")
  end
end
