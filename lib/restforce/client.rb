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

  private

    def connection
      @connection ||= Faraday.new(:url => "https://#{@options[:host]}") do |builder|
        builder.request :json
        builder.response :json
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
