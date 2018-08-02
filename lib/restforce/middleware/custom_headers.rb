# frozen_string_literal: true

module Restforce
  # Middleware that allows you to specify custom request headers
  # when initializing Restforce client
  class Middleware::CustomHeaders < Restforce::Middleware
    def call(env)
      headers = @options[:request_headers]
      env[:request_headers].merge!(headers) if headers.is_a?(Hash)

      @app.call(env)
    end
  end
end
