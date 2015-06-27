require 'forwardable'

module Restforce
  class Middleware::Logger < Faraday::Response::Middleware
    extend Forwardable

    def initialize(app, logger, options)
      super(app)
      @options = options
      @logger = logger || begin
        require 'logger'
        ::Logger.new(STDOUT)
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
      super
    end

    def on_complete(env)
      debug('response') do
        dump status: env[:status].to_s,
          headers: env[:response_headers],
          body: env[:body]
      end
    end

    def dump(hash)
      "\n" + hash.map { |k, v| "  #{k}: #{v.inspect}" }.join("\n")
    end
  end
end
