module Restforce
  class Client

    def initialize(options)
      raise 'Please specify a hash of options' unless options.is_a?(Hash)
      @options = {
        :username       => Restforce.configuration.username,
        :password       => Restforce.configuration.password,
        :security_token => Restforce.configuration.security_token,
        :client_id      => Restforce.configuration.client_id,
        :client_secret  => Restforce.configuration.client_secret,
        :host           => Restforce.configuration.host,
        :api_version    => Restforce.configuration.api_version,
        :oauth_token    => Restforce.configuration.oauth_token,
        :refresh_token  => Restforce.configuration.refresh_token,
        :instance_url   => Restforce.configuration.instance_url
      }.merge(options)
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
        builder.use Restforce::Middleware::Authentication
        builder.adapter Faraday.default_adapter
      end
      @connection.headers['Authorization'] = "OAuth #{oauth_token}" if oauth_token
      @connection
    end

    def oauth_token
      @options[:oauth_token]
    end

  end
end
