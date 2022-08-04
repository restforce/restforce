# frozen_string_literal: true

require 'forwardable'

module Restforce
  class Middleware::Logger < Faraday::Middleware
    extend Forwardable

    def initialize(app, logger, options)
      super(app)
      @options = options
      @logger = logger || begin
        require 'logger'
        ::Logger.new($stdout)
      end
    end

    def_delegators :@logger, :debug, :info, :warn, :error, :fatal

    def call(env)
      debug('request') do
        dump url: env[:url].to_s,
             method: env[:method],
             headers: env[:request_headers],
             body: env[:body]
      end

      on_request(env) if respond_to?(:on_request)
      @app.call(env).on_complete do |environment|
        on_complete(environment) if respond_to?(:on_complete)
      end
    end

    def on_complete(env)
      debug('response') do
        dump status: env[:status].to_s,
             headers: env[:response_headers],
             body: env[:body]
      end
    end

    def dump(hash)
      dumped_pairs = hash.map { |k, v| "  #{k}: #{v.inspect}" }.join("\n")
      "\n#{dumped_pairs}"
    end
  end
end
