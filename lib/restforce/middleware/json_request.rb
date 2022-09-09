# frozen_string_literal: true

#
# Adapted from `lib/faraday/request/json.rb` in the `faraday`
# gem (<https://github.com/lostisland/faraday/blob/5366029282968d59980a182258f8c2b0212721c8/lib/faraday/request/json.rb>).
#
# We use this because we want to support Faraday 1.x and Faraday 2.x.
# Faraday 2.x has the JSON middlewares included, but Faraday 1.x doesn't,
# forcing you to use the `faraday_middleware` gem. This approach allows us
# to support both.
#
# Copyright (c) 2009-2022 Rick Olson, Zack Hobson
# Licensed under the MIT License.
#
require 'json'

module Restforce
  # Request middleware that encodes the body as JSON.
  #
  # Processes only requests with matching Content-type or those without a type.
  # If a request doesn't have a type but has a body, it sets the Content-type
  # to JSON MIME-type.
  #
  # Doesn't try to encode bodies that already are in string form.
  # rubocop:disable Style/ClassAndModuleChildren
  class Middleware::JsonRequest < Faraday::Middleware
    # rubocop:enable Style/ClassAndModuleChildren

    # This is the only line that differs substantively from the version in
    # Faraday. In Faraday, this refers to a Faraday constant.
    CONTENT_TYPE = 'Content-Type'

    MIME_TYPE = 'application/json'
    MIME_TYPE_REGEX = %r{^application/(vnd\..+\+)?json$}.freeze

    #
    # Taken from `lib/faraday/middleware.rb` in the `faraday`
    # gem (<https://github.com/lostisland/faraday/blob/08b7d4d/lib/faraday/middleware.rb>),
    # with a tiny adaptation to refer to the `@app` instance
    # variable rather than expecting an `attr_reader` to exist.
    #
    # In Faraday versions before v1.2.0, `#call`  is missing.
    #
    # Copyright (c) 2009-2022 Rick Olson, Zack Hobson
    # Licensed under the MIT License.
    #
    def call(env)
      on_request(env) if respond_to?(:on_request)
      @app.call(env).on_complete do |environment|
        on_complete(environment) if respond_to?(:on_complete)
      end
    end

    def on_request(env)
      match_content_type(env) do |data|
        env[:body] = encode(data)
      end
    end

    private

    def encode(data)
      ::JSON.generate(data)
    end

    def match_content_type(env)
      return unless process_request?(env)

      env[:request_headers][CONTENT_TYPE] ||= MIME_TYPE
      yield env[:body] unless env[:body].respond_to?(:to_str)
    end

    def process_request?(env)
      type = request_type(env)
      body?(env) && (type.empty? || type.match?(MIME_TYPE_REGEX))
    end

    def body?(env)
      (body = env[:body]) && !(body.respond_to?(:to_str) && body.empty?)
    end

    def request_type(env)
      type = env[:request_headers][CONTENT_TYPE].to_s
      type = type.split(';', 2).first if type.index(';')
      type
    end
  end
end

Faraday::Request.register_middleware(json: Restforce::Middleware::JsonRequest)
