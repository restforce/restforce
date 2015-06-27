module Restforce
  # Base class that all middleware can extend. Provides some convenient helper
  # functions.
  class Middleware < Faraday::Middleware
    autoload :RaiseError,     'restforce/middleware/raise_error'
    autoload :Authentication, 'restforce/middleware/authentication'
    autoload :Authorization,  'restforce/middleware/authorization'
    autoload :InstanceURL,    'restforce/middleware/instance_url'
    autoload :Multipart,      'restforce/middleware/multipart'
    autoload :Mashify,        'restforce/middleware/mashify'
    autoload :Caching,        'restforce/middleware/caching'
    autoload :Logger,         'restforce/middleware/logger'
    autoload :Gzip,           'restforce/middleware/gzip'

    def initialize(app, client, options)
      @app = app
      @client = client
      @options = options
    end

    # Internal: Proxy to the client.
    def client
      @client
    end

    # Internal: Proxy to the client's faraday connection.
    def connection
      client.send(:connection)
    end
  end
end
