module Restforce
  # Middleware the converts sobject records from JSON into Restforce::SObject objects
  # and collections of records into Restforce::Collection objects.
  class Middleware::Mashify < Restforce::Middleware

    def call(env)
      @app.call(env).on_complete do |env|
        env[:body] = Restforce::Mash.build(env[:body], client)
      end
    end
  end
end
