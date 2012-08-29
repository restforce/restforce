module FixtureHelpers

  def stub_api_request(endpoint, options = {})
    options = {
      :method => :get,
      :status => 200,
      :api_version => '24.0',
      :with => nil
    }.merge(options)

    stub_request(:get, "https://login.salesforce.com/services/data/v#{options[:api_version]}/#{endpoint}").
      to_return(:status => options[:status], :body => fixture(options[:with]))
  end

  def fixture(f)
    File.read(File.expand_path("../../fixtures/#{f}.json", __FILE__))
  end

end
