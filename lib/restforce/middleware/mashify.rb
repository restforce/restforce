module Restforce

  # Middleware the converts sobject records from JSON into Restforce::SObject objects
  # and collections of records into Restforce::Collection objects.
  #
  # If the response body contains a top level 'records' key, the response will
  # be converted into a Restforce::Collection.
  class Middleware::Mashify < Restforce::Middleware

    def call(env)
      response = @app.call(env)
      env[:body] = Restforce::Collection.new(env[:body]) if env[:body].has_key?('records')
      response
    end
  
  end
  
end
