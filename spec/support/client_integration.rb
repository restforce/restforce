# frozen_string_literal: true

module ClientIntegrationExampleGroup
  def self.included(base)
    base.class_eval do
      let(:oauth_token) do
        '00Dx0000000BV7z!AR8AQAxo9UfVkh8AlV0Gomt9Czx9LjHnSSpwBMmbRcgKFmxOtvxjTrKW19ye6P' \
          'E3Ds1eQz3z8jr3W7_VbWmEu4Q8TVGSTHxs'
      end

      let(:refresh_token)  { 'refresh' }
      let(:instance_url)   { 'https://na1.salesforce.com' }
      let(:username)       { 'foo'            }
      let(:password)       { 'bar'            }
      let(:security_token) { 'security_token' }
      let(:client_id)      { 'client_id'      }
      let(:client_secret)  { 'client_secret'  }
      let(:cache)          { nil }

      let(:base_options) do
        {
          oauth_token: oauth_token,
          refresh_token: refresh_token,
          instance_url: instance_url,
          username: username,
          password: password,
          security_token: security_token,
          client_id: client_id,
          client_secret: client_secret,
          cache: cache,
          request_headers: { 'x-test-header' => 'Test Header' }
        }
      end

      let(:client_options) { base_options }

      subject(:client) { described_class.new client_options }
    end
  end

  RSpec.configure do |config|
    describes = lambda do |described|
      described <= Restforce::AbstractClient
    end

    config.include self,
                   file_path: %r{spec/integration},
                   describes: describes

    config.before mashify: false do
      base_options.merge!(mashify: false)
    end
  end
end
