module Restforce
  class Middleware::Logger < Faraday::Response::Logger
    def call(env)
      info "#{env[:method]} #{env[:url].to_s}"
      debug('request headers') { dump_headers env[:request_headers] }
      debug('request body') { env[:body] }
      super
    end

    def on_complete(env)
      info('Status') { env[:status].to_s }
      debug('response headers') { dump_headers env[:response_headers] }
      debug('response body') { env[:body] }
    end
  end
end
