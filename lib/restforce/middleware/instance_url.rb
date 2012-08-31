module Restforce

  # Middleware which asserts that the instance_url is always set
  class Middleware::InstanceURL < Restforce::Middleware

    def call(env)
      # If the instance url isn't set in options, raise a
      # Faraday::Error::ClientError to trigger reauthentication.
      raise Faraday::Error::ClientError, 'instance url not set' unless @options[:instance_url]

      # If the url_prefix for the connection doesn't match the instance_url
      # set in the options, we raise an error which gets caught outside of
      # middleware, where the url_prefix is then set before retrying the
      # request. It would be ideal if this could all be handled in
      # middleware...
      raise Restforce::InstanceURLError unless connection.url_prefix == instance_url

      @app.call(env)
    end

    def instance_url
      URI.parse(@options[:instance_url])
    end

    def connection
      @client.send(:connection)
    end
  
  end

end
