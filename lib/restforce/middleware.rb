module Restforce

  # Base class that all middleware can extend. Provides some convenient helper
  # functions.
  class Middleware < Faraday::Middleware

    def initialize(app, client, options)
      @app     = app
      @client  = client
      @options = options
    end

    def client
      @client
    end

    def connection
      client.send(:connection)
    end

  end
end

require 'restforce/middleware/raise_error'
require 'restforce/middleware/authentication'
require 'restforce/middleware/authentication/password'
require 'restforce/middleware/authentication/token'
require 'restforce/middleware/authorization'
require 'restforce/middleware/instance_url'
require 'restforce/middleware/mashify'
require 'restforce/middleware/multipart'
require 'restforce/middleware/caching'
