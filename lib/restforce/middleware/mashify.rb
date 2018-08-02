# frozen_string_literal: true

module Restforce
  # Middleware the converts sobject records from JSON into Restforce::SObject objects
  # and collections of records into Restforce::Collection objects.
  class Middleware::Mashify < Restforce::Middleware
    def call(env)
      @app.call(env).on_complete do |completed_env|
        completed_env[:body] = Restforce::Mash.build(completed_env[:body], client)
      end
    end
  end
end
