module Restforce
  class Client

    def initialize(options)
      raise 'Please specify a hash of options' unless options.is_a?(Hash)
      @options = {}.tap do |options|
        [:username, :password, :security_token, :client_id, :client_secret, :host,
         :api_version, :oauth_token, :refresh_token, :instance_url].each do |option|
          options[option] = Restforce.configuration.send option
        end
      end
      @options.merge!(options)
    end

    def describe_sobjects
      response = get api_path('sobjects')
      response.body['sobjects']
    end

    def list_sobjects
      describe_sobjects.collect { |sobject| sobject['name'] }
    end

    # Helper methods for performing abritrary actions against the API using
    # various HTTP verbs
    [:get, :post, :put, :delete].each do |method|
      define_method method do |*args|
        connection.send method, *args
      end
    end

  private

    def api_path(path)
      "/services/data/v#{@options[:api_version]}/#{path}"
    end

    def connection
      @connection ||= Faraday.new(:url => "https://#{@options[:host]}") do |builder|
        builder.request :json
        builder.response :json
        builder.use Restforce::Middleware::PasswordAuthentication, @options
        builder.use Restforce::Middleware::Authorization, @options
        builder.response :raise_error
        builder.adapter Faraday.default_adapter
      end
      @connection
    end

  end
end
