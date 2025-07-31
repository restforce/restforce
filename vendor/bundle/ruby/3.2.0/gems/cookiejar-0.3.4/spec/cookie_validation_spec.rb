require 'spec_helper'

include CookieJar
describe CookieValidation do
  describe '#validate_cookie' do
    localaddr = 'http://localhost/foo/bar/'
    it 'should fail if version unset' do
      expect {
        unversioned = Cookie.from_set_cookie localaddr, 'foo=bar'
        unversioned.instance_variable_set :@version, nil
        CookieValidation.validate_cookie localaddr, unversioned
      }.to raise_error InvalidCookieError
    end
    it 'should fail if the path is more specific' do
      expect {
        Cookie.from_set_cookie localaddr, 'foo=bar;path=/foo/bar/baz'
      }.to raise_error InvalidCookieError
    end
    it 'should fail if the path is different than the request' do
      expect {
        Cookie.from_set_cookie localaddr, 'foo=bar;path=/baz/'
      }.to raise_error InvalidCookieError
    end
    it 'should fail if the domain has no dots' do
      expect {
        Cookie.from_set_cookie 'http://zero/', 'foo=bar;domain=zero'
      }.to raise_error InvalidCookieError
    end
    it 'should fail for explicit localhost' do
      expect {
        Cookie.from_set_cookie localaddr, 'foo=bar;domain=localhost'
      }.to raise_error InvalidCookieError
    end
    it 'should fail for mismatched domains' do
      expect {
        Cookie.from_set_cookie 'http://www.foo.com/', 'foo=bar;domain=bar.com'
      }.to raise_error InvalidCookieError
    end
    it 'should fail for domains more than one level up' do
      expect {
        Cookie.from_set_cookie 'http://x.y.z.com/', 'foo=bar;domain=z.com'
      }.to raise_error InvalidCookieError
    end
    it 'should fail for setting subdomain cookies' do
      expect {
        Cookie.from_set_cookie 'http://foo.com/', 'foo=bar;domain=auth.foo.com'
      }.to raise_error InvalidCookieError
    end
    it 'should handle a normal implicit internet cookie' do
      normal = Cookie.from_set_cookie 'http://foo.com/', 'foo=bar'
      expect(CookieValidation.validate_cookie('http://foo.com/', normal)).to be_truthy
    end
    it 'should handle a normal implicit localhost cookie' do
      localhost = Cookie.from_set_cookie 'http://localhost/', 'foo=bar'
      expect(CookieValidation.validate_cookie('http://localhost/', localhost)).to be_truthy
    end
    it 'should handle an implicit IP address cookie' do
      ipaddr = Cookie.from_set_cookie 'http://127.0.0.1/', 'foo=bar'
      expect(CookieValidation.validate_cookie('http://127.0.0.1/', ipaddr)).to be_truthy
    end
    it 'should handle an explicit domain on an internet site' do
      explicit = Cookie.from_set_cookie 'http://foo.com/', 'foo=bar;domain=.foo.com'
      expect(CookieValidation.validate_cookie('http://foo.com/', explicit)).to be_truthy
    end
    it 'should handle setting a cookie explicitly on a superdomain' do
      superdomain = Cookie.from_set_cookie 'http://auth.foo.com/', 'foo=bar;domain=.foo.com'
      expect(CookieValidation.validate_cookie('http://foo.com/', superdomain)).to be_truthy
    end
    it 'should handle explicitly setting a cookie' do
      explicit = Cookie.from_set_cookie 'http://foo.com/bar/', 'foo=bar;path=/bar/'
      CookieValidation.validate_cookie('http://foo.com/bar/', explicit)
    end
    it 'should handle setting a cookie on a higher path' do
      higher = Cookie.from_set_cookie 'http://foo.com/bar/baz/', 'foo=bar;path=/bar/'
      CookieValidation.validate_cookie('http://foo.com/bar/baz/', higher)
    end
  end
  describe '#cookie_base_path' do
    it "should leave '/' alone" do
      expect(CookieValidation.cookie_base_path('/')).to eq '/'
    end
    it "should strip off everything after the last '/'" do
      expect(CookieValidation.cookie_base_path('/foo/bar/baz')).to eq '/foo/bar/'
    end
    it 'should handle query parameters and fragments with slashes' do
      expect(CookieValidation.cookie_base_path('/foo/bar?query=a/b/c#fragment/b/c')).to eq '/foo/'
    end
    it 'should handle URI objects' do
      expect(CookieValidation.cookie_base_path(URI.parse('http://www.foo.com/bar/'))).to eq '/bar/'
    end
    it 'should preserve case' do
      expect(CookieValidation.cookie_base_path('/BaR/')).to eq '/BaR/'
    end
  end
  describe '#determine_cookie_path' do
    it 'should use the requested path when none is specified for the cookie' do
      expect(CookieValidation.determine_cookie_path('http://foo.com/', nil)).to eq '/'
      expect(CookieValidation.determine_cookie_path('http://foo.com/bar/baz', '')).to eq '/bar/'
    end
    it 'should handle URI objects' do
      expect(CookieValidation.determine_cookie_path(URI.parse('http://foo.com/bar/'), '')).to eq '/bar/'
    end
    it 'should handle Cookie objects' do
      cookie = Cookie.from_set_cookie('http://foo.com/', 'name=value;path=/')
      expect(CookieValidation.determine_cookie_path('http://foo.com/', cookie)).to eq '/'
    end
    it 'should ignore the request when a path is specified' do
      expect(CookieValidation.determine_cookie_path('http://foo.com/ignorable/path', '/path/')).to eq '/path/'
    end
  end
  describe '#compute_search_domains' do
    it 'should handle subdomains' do
      expect(CookieValidation.compute_search_domains('http://www.auth.foo.com/')).to eq(
        ['www.auth.foo.com', '.www.auth.foo.com', '.auth.foo.com'])
    end
    it 'should handle root domains' do
      expect(CookieValidation.compute_search_domains('http://foo.com/')).to eq(
        ['foo.com', '.foo.com'])
    end
    it 'should handle hexadecimal TLDs' do
      expect(CookieValidation.compute_search_domains('http://tiny.cc/')).to eq(
        ['tiny.cc', '.tiny.cc'])
    end
    it 'should handle IP addresses' do
      expect(CookieValidation.compute_search_domains('http://127.0.0.1/')).to eq(
        ['127.0.0.1'])
    end
    it 'should handle local addresses' do
      expect(CookieValidation.compute_search_domains('http://zero/')).to eq(
        ['zero.local', '.zero.local', '.local'])
    end
  end
  describe '#determine_cookie_domain' do
    it 'should add a dot to the front of domains' do
      expect(CookieValidation.determine_cookie_domain('http://foo.com/', 'foo.com')).to eq '.foo.com'
    end
    it 'should not add a second dot if one present' do
      expect(CookieValidation.determine_cookie_domain('http://foo.com/', '.foo.com')).to eq '.foo.com'
    end
    it 'should handle Cookie objects' do
      c = Cookie.from_set_cookie('http://foo.com/', 'foo=bar;domain=foo.com')
      expect(CookieValidation.determine_cookie_domain('http://foo.com/', c)).to eq '.foo.com'
    end
    it 'should handle URI objects' do
      expect(CookieValidation.determine_cookie_domain(URI.parse('http://foo.com/'), '.foo.com')).to eq '.foo.com'
    end
    it 'should use an exact hostname when no domain specified' do
      expect(CookieValidation.determine_cookie_domain('http://foo.com/', '')).to eq 'foo.com'
    end
    it 'should leave IPv4 addresses alone' do
      expect(CookieValidation.determine_cookie_domain('http://127.0.0.1/', '127.0.0.1')).to eq '127.0.0.1'
    end
    it 'should leave IPv6 addresses alone' do
      ['2001:db8:85a3::8a2e:370:7334', '::ffff:192.0.2.128'].each do |value|
        expect(CookieValidation.determine_cookie_domain("http://[#{value}]/", value)).to eq value
      end
    end
  end
  describe '#effective_host' do
    it 'should leave proper domains the same' do
      ['google.com', 'www.google.com', 'google.com.'].each do |value|
        expect(CookieValidation.effective_host(value)).to eq  value
      end
    end
    it 'should handle a URI object' do
      expect(CookieValidation.effective_host(URI.parse('http://example.com/'))).to eq 'example.com'
    end
    it 'should add a local suffix on unqualified hosts' do
      expect(CookieValidation.effective_host('localhost')).to eq 'localhost.local'
    end
    it 'should leave IPv4 addresses alone' do
      expect(CookieValidation.effective_host('127.0.0.1')).to eq '127.0.0.1'
    end
    it 'should leave IPv6 addresses alone' do
      ['2001:db8:85a3::8a2e:370:7334', ':ffff:192.0.2.128'].each do |value|
        expect(CookieValidation.effective_host(value)).to eq value
      end
    end
    it 'should lowercase addresses' do
      expect(CookieValidation.effective_host('FOO.COM')).to eq 'foo.com'
    end
  end
  describe '#match_domains' do
    it 'should handle exact matches' do
      expect(CookieValidation.domains_match('localhost.local', 'localhost.local')).to eq 'localhost.local'
      expect(CookieValidation.domains_match('foo.com', 'foo.com')).to eq 'foo.com'
      expect(CookieValidation.domains_match('127.0.0.1', '127.0.0.1')).to eq '127.0.0.1'
      expect(CookieValidation.domains_match('::ffff:192.0.2.128', '::ffff:192.0.2.128')).to eq '::ffff:192.0.2.128'
    end
    it 'should handle matching a superdomain' do
      expect(CookieValidation.domains_match('.foo.com', 'auth.foo.com')).to eq '.foo.com'
      expect(CookieValidation.domains_match('.y.z.foo.com', 'x.y.z.foo.com')).to eq '.y.z.foo.com'
    end
    it 'should not match superdomains, or illegal domains' do
      expect(CookieValidation.domains_match('.z.foo.com', 'x.y.z.foo.com')).to be_nil
      expect(CookieValidation.domains_match('foo.com', 'com')).to be_nil
    end
    it 'should not match domains with and without a dot suffix together' do
      expect(CookieValidation.domains_match('foo.com.', 'foo.com')).to be_nil
    end
  end
  describe '#hostname_reach' do
    it 'should find the next highest subdomain' do
      { 'www.google.com' => 'google.com', 'auth.corp.companyx.com' => 'corp.companyx.com' }.each do |entry|
        expect(CookieValidation.hostname_reach(entry[0])).to eq entry[1]
      end
    end
    it 'should handle domains with suffixed dots' do
      expect(CookieValidation.hostname_reach('www.google.com.')).to eq 'google.com.'
    end
    it 'should return nil for a root domain' do
      expect(CookieValidation.hostname_reach('github.com')).to be_nil
    end
    it "should return 'local' for a local domain" do
      ['foo.local', 'foo.local.'].each do |hostname|
        expect(CookieValidation.hostname_reach(hostname)).to eq 'local'
      end
    end
    it "should handle mixed-case '.local'" do
      expect(CookieValidation.hostname_reach('foo.LOCAL')).to eq 'local'
    end
    it 'should return nil for an IPv4 address' do
      expect(CookieValidation.hostname_reach('127.0.0.1')).to be_nil
    end
    it 'should return nil for IPv6 addresses' do
      ['2001:db8:85a3::8a2e:370:7334', '::ffff:192.0.2.128'].each do |value|
        expect(CookieValidation.hostname_reach(value)).to be_nil
      end
    end
  end
  describe '#parse_set_cookie' do
    it 'should max out at 2038 on 32bit systems' do
      expect(CookieValidation.parse_set_cookie('TRACK_USER_P=98237480810003948000782774;expires=Sat, 30-Jun-2040 05:39:49 GMT;path=/')[:expires_at].to_i).to be >= 0x7FFFFFFF
    end
  end
end
