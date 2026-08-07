# frozen_string_literal: true

shared_examples_for 'build_option_url' do |clazz, requirements, url|
  requirements.each_key.each do |key_to_be_removed|
    it "should raise an error if #{key_to_be_removed} is missing" do
      expect do
        incomplete = requirements.reject { |k, _v| k == key_to_be_removed }
        clazz.build_option_url(incomplete)
      end.to raise_error(an_instance_of(ArgumentError))
    end
  end

  it "should NOT raise an error if api_version is missing" do
    expect do
      clazz.build_option_url(requirements)
    end.not_to raise_error(ArgumentError)
  end

  it "should bring build a url option" do
    options = clazz.build_option_url(requirements)
    expect(options[:url]).to eq(url)
  end
end

shared_examples_for 'an class that takes an optional body' do |clazz|
  it "should not have a 'body' key when it is not passed in" do
    object = clazz.new(:get, sobject_name: 'Account', url: "url")
    expect(object.to_hash).to eql({ method: 'GET', url: 'url' })
  end

  it "should have a 'body' when passed in" do
    object = clazz.new(:patch,
                       sobject_name: 'Account',
                       body: { name: 'Foo' },
                       url: "url")
    expect(object.to_hash).to eql({
                                    method: 'PATCH',
                                    url: 'url',
                                    body: { name: 'Foo' }
                                  })
  end
end

shared_examples_for 'a query resource' do |clazz, endpoint|
  describe "#to_hash" do
    it "should have the correct keys" do
      expect(clazz.new(:get, url: 'url').
        to_hash).to eql({ method: 'GET', url: 'url' })
    end
  end

  describe ".build_option_url" do
    it_behaves_like 'build_option_url',
                    clazz,
                    { soql: "select field from account where id = " \
                            "'@{ref.results[0].addresses[0].Id}'",
                      api_version: '50' },
                    "/services/data/v50/#{endpoint}?q=select+field+from+account" \
                    "+where+id+%3D+%27@{ref.results[0].addresses[0].Id}%27"
  end
end
