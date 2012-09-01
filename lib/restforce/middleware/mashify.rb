module Restforce

  # Middleware the converts sobject records from JSON into Restforce::SObject objects
  # and collections of records into Restforce::Collection objects.
  #
  # If the response body contains a top level 'records' key, the response will
  # be converted into a Restforce::Collection.
  class Middleware::Mashify < Restforce::Middleware

    def call(env)
      @env = env
      response = @app.call(env)
      if collection?
        env[:body] = Restforce::Collection.new(body, client)
      else
        env[:body] = Hashie::Mash.new(body)
      end
      response
    end

    def body
      @env[:body]
    end

    def collection?
      body.is_a?(Hash) && body.has_key?('records')
    end
  
  end
  
end
