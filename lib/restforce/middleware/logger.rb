module Restforce
  class Middleware::Logger < Faraday::Response::Logger
    def on_complete(env)
      info('Status') { env[:status].to_s }
      debug('response headers') { dump_headers env[:response_headers] }
      debug('response body') { env[:body] }
    end
  end
end
