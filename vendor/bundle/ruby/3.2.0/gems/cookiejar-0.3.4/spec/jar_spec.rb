require 'spec_helper'

include CookieJar

describe Jar do
  describe '.setCookie' do
    it 'should allow me to set a cookie' do
      jar = Jar.new
      jar.set_cookie 'http://foo.com/', 'foo=bar'
    end
    it 'should allow me to set multiple cookies' do
      jar = Jar.new
      jar.set_cookie 'http://foo.com/', 'foo=bar'
      jar.set_cookie 'http://foo.com/', 'bar=baz'
      jar.set_cookie 'http://auth.foo.com/', 'foo=bar'
      jar.set_cookie 'http://auth.foo.com/', 'auth=135121...;domain=foo.com'
    end
    it 'should allow me to set multiple cookies in 1 header' do
      jar = Jar.new
      jar.set_cookie 'http://foo.com/', 'my_cookie=123456; Domain=foo.com; expires=Thu, 31 Dec 2037 23:59:59 GMT; Path=/, other_cookie=helloworld; Domain=foo.com; expires=Thu, 31 Dec 2037 23:59:59 GMT, last_cookie=098765'
    end
  end
  describe '.get_cookies' do
    it 'should let me read back cookies which are set' do
      jar = Jar.new
      jar.set_cookie 'http://foo.com/', 'foo=bar'
      jar.set_cookie 'http://foo.com/', 'bar=baz'
      jar.set_cookie 'http://auth.foo.com/', 'foo=bar'
      jar.set_cookie 'http://auth.foo.com/', 'auth=135121...;domain=foo.com'
      expect(jar.get_cookies('http://foo.com/')).to have(3).items
    end
    it 'should let me read back a multiple cookies from 1 header' do
      jar = Jar.new
      jar.set_cookie 'http://foo.com/', 'my_cookie=123456; Domain=foo.com; expires=Thu, 31 Dec 2037 23:59:59 GMT; Path=/, other_cookie=helloworld; Domain=foo.com; expires=Thu, 31 Dec 2037 23:59:59 GMT, last_cookie=098765'
      expect(jar.get_cookie_header('http://foo.com/')).to eq 'last_cookie=098765;my_cookie=123456;other_cookie=helloworld'
    end
    it 'should return cookies longest path first' do
      jar = Jar.new
      uri = 'http://foo.com/a/b/c/d'
      jar.set_cookie uri, 'a=bar'
      jar.set_cookie uri, 'b=baz;path=/a/b/c/d'
      jar.set_cookie uri, 'c=bar;path=/a/b'
      jar.set_cookie uri, 'd=bar;path=/a/'
      cookies = jar.get_cookies(uri)
      expect(cookies).to have(4).items
      expect(cookies[0].name).to eq 'b'
      expect(cookies[1].name).to eq 'a'
      expect(cookies[2].name).to eq 'c'
      expect(cookies[3].name).to eq 'd'
    end
    it 'should not return expired cookies' do
      jar = Jar.new
      uri = 'http://localhost/'
      jar.set_cookie uri, 'foo=bar;expires=Wednesday, 09-Nov-99 23:12:40 GMT'
      cookies = jar.get_cookies(uri)
      expect(cookies).to have(0).items
    end
  end
  describe '.get_cookie_headers' do
    it 'should return cookie headers' do
      jar = Jar.new
      uri = 'http://foo.com/a/b/c/d'
      jar.set_cookie uri, 'a=bar'
      jar.set_cookie uri, 'b=baz;path=/a/b/c/d'
      cookie_headers = jar.get_cookie_header uri
      expect(cookie_headers).to eq 'b=baz;a=bar'
    end
    it 'should handle a version 1 cookie' do
      jar = Jar.new
      uri = 'http://foo.com/a/b/c/d'
      jar.set_cookie uri, 'a=bar'
      jar.set_cookie uri, 'b=baz;path=/a/b/c/d'
      jar.set_cookie2 uri, 'c=baz;Version=1;path="/"'
      cookie_headers = jar.get_cookie_header uri
      expect(cookie_headers).to eq '$Version=0;b=baz;$Path="/a/b/c/d";a=bar;$Path="/a/b/c/",$Version=1;c=baz;$Path="/"'
    end
  end
  describe '.add_cookie' do
    it 'should let me add a pre-existing cookie' do
      jar = Jar.new
      cookie = Cookie.from_set_cookie 'http://localhost/', 'foo=bar'
      jar.add_cookie cookie
    end
  end
  describe '.to_a' do
    it 'should return me an array of all cookie objects' do
      uri = 'http://foo.com/a/b/c/d'
      jar = Jar.new
      jar.set_cookie uri, 'a=bar;expires=Wednesday, 09-Nov-99 23:12:40 GMT'
      jar.set_cookie uri, 'b=baz;path=/a/b/c/d'
      jar.set_cookie uri, 'c=bar;path=/a/b'
      jar.set_cookie uri, 'd=bar;path=/a/'
      jar.set_cookie 'http://localhost/', 'foo=bar'
      expect(jar.to_a).to have(5).items
    end
  end
  describe '.expire_cookies' do
    it 'should expire cookies which are no longer valid' do
      uri = 'http://foo.com/a/b/c/d'
      jar = Jar.new
      jar.set_cookie uri, 'a=bar;expires=Wednesday, 09-Nov-99 23:12:40 GMT'
      jar.set_cookie uri, 'b=baz;path=/a/b/c/d;expires=Wednesday, 01-Nov-2028 12:00:00 GMT'
      jar.set_cookie uri, 'c=bar;path=/a/b'
      jar.set_cookie uri, 'd=bar;path=/a/'
      jar.set_cookie 'http://localhost/', 'foo=bar'
      expect(jar.to_a).to have(5).items
      jar.expire_cookies
      expect(jar.to_a).to have(4).items
    end
    it 'should let me expire all session cookies' do
      uri = 'http://foo.com/a/b/c/d'
      jar = Jar.new
      jar.set_cookie uri, 'a=bar;expires=Wednesday, 09-Nov-99 23:12:40 GMT'
      jar.set_cookie uri, 'b=baz;path=/a/b/c/d;expires=Wednesday, 01-Nov-2028 12:00:00 GMT'
      jar.set_cookie uri, 'c=bar;path=/a/b'
      jar.set_cookie uri, 'd=bar;path=/a/'
      jar.set_cookie 'http://localhost/', 'foo=bar'
      expect(jar.to_a).to have(5).items
      jar.expire_cookies true
      expect(jar.to_a).to have(1).items
    end
  end
  describe '#set_cookies_from_headers' do
    it 'should handle a Set-Cookie header' do
      jar = Jar.new
      cookies = jar.set_cookies_from_headers 'http://localhost/',
                                             'Set-Cookie' => 'foo=bar'
      expect(cookies).to have(1).items
      expect(jar.to_a).to have(1).items
    end
    it 'should handle a set-cookie header' do
      jar = Jar.new
      cookies = jar.set_cookies_from_headers 'http://localhost/',
                                             'set-cookie' => 'foo=bar'
      expect(cookies).to have(1).items
      expect(jar.to_a).to have(1).items
    end
    it 'should handle multiple Set-Cookie headers' do
      jar = Jar.new
      cookies = jar.set_cookies_from_headers 'http://localhost/',
                                             'Set-Cookie' => ['foo=bar', 'bar=baz']
      expect(cookies).to have(2).items
      expect(jar.to_a).to have(2).items
    end
    it 'should handle a Set-Cookie2 header' do
      jar = Jar.new
      cookies = jar.set_cookies_from_headers 'http://localhost/',
                                             'Set-Cookie2' => 'foo=bar;Version=1'
      expect(cookies).to have(1).items
      expect(jar.to_a).to have(1).items
    end
    it 'should handle a set-cookie2 header' do
      jar = Jar.new
      cookies = jar.set_cookies_from_headers 'http://localhost/',
                                             'set-cookie2' => 'foo=bar;Version=1'
      expect(cookies).to have(1).items
      expect(jar.to_a).to have(1).items
    end
    it 'should handle multiple Set-Cookie2 headers' do
      jar = Jar.new
      cookies = jar.set_cookies_from_headers 'http://localhost/',
                                             'Set-Cookie2' => ['foo=bar;Version=1', 'bar=baz;Version=1']
      expect(cookies).to have(2).items
      expect(jar.to_a).to have(2).items
    end
    it 'should handle mixed distinct Set-Cookie and Set-Cookie2 headers' do
      jar = Jar.new
      cookies = jar.set_cookies_from_headers 'http://localhost/',
                                             'Set-Cookie' => 'foo=bar',
                                             'Set-Cookie2' => 'bar=baz;Version=1'
      expect(cookies).to have(2).items
      expect(jar.to_a).to have(2).items
    end
    it 'should handle overlapping Set-Cookie and Set-Cookie2 headers' do
      jar = Jar.new
      cookies = jar.set_cookies_from_headers 'http://localhost/',
                                             'Set-Cookie' => ['foo=bar', 'bar=baz'],
                                             'Set-Cookie2' => 'foo=bar;Version=1'
      expect(cookies).to have(2).items
      expect(jar.to_a).to have(2).items
      # and has the version 1 cookie
      expect(cookies.find do |cookie|
        cookie.name == 'foo'
      end.version).to eq 1
    end
    it 'should silently drop invalid cookies' do
      jar = Jar.new
      cookies = jar.set_cookies_from_headers 'http://localhost/',
                                             'Set-Cookie' => ['foo=bar', 'bar=baz;domain=.foo.com']
      expect(cookies).to have(1).items
      expect(jar.to_a).to have(1).items
    end
  end
  begin
    require 'json'
    describe '.to_json' do
      it 'should serialize cookies to JSON' do
        c = Cookie.from_set_cookie 'https://localhost/', 'foo=bar;secure;expires=Wed, 01-Nov-2028 12:00:00 GMT'
        jar = Jar.new
        jar.add_cookie c
        json = jar.to_json
        expect(json).to be_a String
      end
    end
    describe '.json_create' do
      it 'should deserialize a JSON array to a jar' do
        json = '[{"name":"foo","value":"bar","domain":"localhost.local","path":"\\/","created_at":"2009-09-11 12:51:03 -0600","expiry":"2028-11-01 12:00:00 GMT","secure":true}]'
        array = JSON.parse json

        jar = Jar.json_create array
        expect(jar.get_cookies('https://localhost/')).to have(1).items
      end
      it 'should deserialize a JSON hash to a jar' do
        json = '{"cookies":[{"name":"foo","value":"bar","domain":"localhost.local","path":"\\/","created_at":"2009-09-11 12:51:03 -0600","expiry":"2028-11-01 12:00:00 GMT","secure":true}]}'
        hash = JSON.parse json

        jar = Jar.json_create hash
        expect(jar.get_cookies('https://localhost/')).to have(1).items
      end

      it 'should automatically deserialize to a jar' do
        json = '{"json_class":"CookieJar::Jar","cookies":[{"name":"foo","value":"bar","domain":"localhost.local","path":"\\/","created_at":"2009-09-11 12:51:03 -0600","expiry":"2028-11-01 12:00:00 GMT","secure":true}]}'
        jar = JSON.parse json, create_additions: true
        expect(jar.get_cookies('https://localhost/')).to have(1).items
      end
    end
  rescue LoadError
    it 'does not appear the JSON library is installed' do
      raise 'please install the JSON library'
    end
  end
end
