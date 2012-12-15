module FixtureHelpers
  module InstanceMethods

    def stub_api_request(endpoint, options={})
      options = {
        :method => :get,
        :status => 200,
        :api_version => '24.0'
      }.merge(options)

      stub = stub_request(options[:method], %r{/services/data/v#{options[:api_version]}/#{endpoint}})
      stub = stub.with(:body => options[:with_body]) if options[:with_body] && !RUBY_VERSION.match(/^1.8/)
      stub = stub.to_return(:status => options[:status], :body => fixture(options[:fixture])) if options[:fixture]
      stub
    end

    def stub_login_request(options={})
      stub = stub_request(:post, "https://login.salesforce.com/services/oauth2/token")
      stub = stub.with(:body => options[:with_body]) if options[:with_body] && !RUBY_VERSION.match(/^1.8/)
      stub
    end

    def fixture(f)
      File.read(File.expand_path("../../fixtures/#{f}.json", __FILE__))
    end

  end

  module ClassMethods
    def requests(endpoint, options={})
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
