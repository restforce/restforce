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
      env[:body] = Restforce::Mash.build(body, client)
      response
    end

    def body
      @env[:body]
    end
  
  end
  
end
