# frozen_string_literal: true

module FixtureHelpers
  module InstanceMethods
    def stub_api_request(endpoint, options = {})
      options = {
        method: :get,
        status: 200,
        api_version: Restforce.configuration.api_version
      }.merge(options)

      stub = stub_request(options[:method],
                          %r{/services/data/v#{options[:api_version]}/#{endpoint}})

      if options[:fixture]
        stub = stub.to_return(status: options[:status],
                              body: fixture(options[:fixture]),
                              headers: { 'Content-Type' => 'application/json' })
      end

      stub
    end

    def stub_login_request(*)
      stub_request(:post, "https://login.salesforce.com/services/oauth2/token")
    end

    def fixture(filename)
      File.read(File.expand_path("../../fixtures/#{filename}.json", __FILE__))
    end
  end

  module ClassMethods
    def requests(endpoint, options = {})
      before do
        (@requests ||= []) << stub_api_request(endpoint, options)
      end

      after do
        @requests.each { |request| expect(request).to have_been_requested }
      end
    end
  end
end

RSpec.configure do |config|
  config.include FixtureHelpers::InstanceMethods
  config.extend FixtureHelpers::ClassMethods
end
