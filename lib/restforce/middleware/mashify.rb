module Restforce

  # Middleware the converts sobject records from JSON into Restforce::SObject objects
  # and collections of records into Restforce::Collection objects.
  class Middleware::Mashify < Restforce::Middleware

    def call(env)
      @app.call(env)
    end
  
  end
  
end
