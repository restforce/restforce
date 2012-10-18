module FixtureHelpers

  def stub_api_request(endpoint, options = {})
    options = {
      :method => :get,
      :status => 200,
      :api_version => '24.0',
      :with => nil
    }.merge(options)

    stub = stub_request(options[:method], %r{/services/data/v#{options[:api_version]}/#{endpoint}})
    stub = stub.with(:body => options[:body]) if options[:body]
    stub = stub.to_return(:status => options[:status], :body => fixture(options[:with])) if options[:with]
    stub
  end

  def stub_login_request(options = {})
    options = {
      :body => nil
    }.merge(options)

    stub = stub_request(:post, "https://login.salesforce.com/services/oauth2/token")
    stub = stub.with(:body => options[:body]) if options[:body]
    stub
  end

  def fixture(f)
    File.read(File.expand_path("../../fixtures/#{f}.json", __FILE__))
  end

end
