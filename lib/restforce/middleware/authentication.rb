module Restforce
  module Middleware
    class Authentication

      def initialize(app, options = {})
        @app = app
        @options = options
      end

      def call(env)
        @app.call(env).on_complete do
        end
      end
    
    end
  end
end
