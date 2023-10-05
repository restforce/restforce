# frozen_string_literal: true

#
# Adapted from `lib/faraday/response/json.rb` in the `faraday`
# gem (<https://github.com/lostisland/faraday/blob/5366029/lib/faraday/response/json.rb>).
#
# Copyright (c) 2009-2022 Rick Olson, Zack Hobson
# Licensed under the MIT License.
#

require 'json'

module Restforce
  # rubocop:disable Style/ClassAndModuleChildren
  class Middleware::JsonResponse < Faraday::Middleware
    # rubocop:enable Style/ClassAndModuleChildren

    # This is the only line that differs substantively from the version in
    # Faraday. In Faraday, this refers to a Faraday constant.
    CONTENT_TYPE = 'Content-Type'

    def initialize(app = nil, parser_options: nil, content_type: /\bjson$/,
                   preserve_raw: false)
      super(app)
      @parser_options = parser_options
      @content_types = Array(content_type)
      @preserve_raw = preserve_raw
    end

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

    def on_complete(env)
      process_response(env) if parse_response?(env)
    end

    private

    def process_response(env)
      env[:raw_body] = env[:body] if @preserve_raw
      env[:body] = parse(env[:body])
    rescue StandardError, SyntaxError => e
      raise Faraday::ParsingError.new(e, env[:response])
    end

    def parse(body)
      ::JSON.parse(body, @parser_options || {}) unless body.strip.empty?
    end

    def parse_response?(env)
      process_response_type?(env) &&
        env[:body].respond_to?(:to_str)
    end

    def process_response_type?(env)
      type = response_type(env)
      @content_types.empty? || @content_types.any? do |pattern|
        pattern.is_a?(Regexp) ? type.match?(pattern) : type == pattern
      end
    end

    def response_type(env)
      type = env[:response_headers][CONTENT_TYPE].to_s
      type = type.split(';', 2).first if type.index(';')
      type
    end
  end
end

Faraday::Response.register_middleware(restforce_json: Restforce::Middleware::JsonResponse)
