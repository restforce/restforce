module Restforce
  class Middleware::RaiseError < Faraday::Response::Middleware
    def on_complete(env)
      case env[:status]
      when 404
        raise Faraday::Error::ResourceNotFound, message(env)
      when 401
        raise Restforce::UnauthorizedError, unauthorized(env)
      when 400...600
        raise Faraday::Error::ClientError, message(env)
      end
    end

    def unauthorized(env)
      "#{env[:body]['error']}: #{env[:body]['error_description']}"
    end

    def message(env)
      "#{env[:body].first['errorCode']}: #{env[:body].first['message']}"
    end
  end
end
