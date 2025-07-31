# frozen_string_literal: true
require 'spec_helper'

include CookieJar

FOO_URL = 'http://localhost/foo'.freeze
AMMO_URL = 'http://localhost/ammo'.freeze
NETSCAPE_SPEC_SET_COOKIE_HEADERS =
  [['CUSTOMER=WILE_E_COYOTE; path=/; expires=Wednesday, 09-Nov-99 23:12:40 GMT',
    FOO_URL],
   ['PART_NUMBER=ROCKET_LAUNCHER_0001; path=/',
    FOO_URL],
   ['SHIPPING=FEDEX; path=/foo',
    FOO_URL],
   ['PART_NUMBER=ROCKET_LAUNCHER_0001; path=/',
    FOO_URL],
   ['PART_NUMBER=RIDING_ROCKET_0023; path=/ammo',
    AMMO_URL]].freeze

describe Cookie do
  describe '#from_set_cookie' do
    it 'should handle cookies from the netscape spec' do
      NETSCAPE_SPEC_SET_COOKIE_HEADERS.each do |value|
        header, url = *value
        Cookie.from_set_cookie url, header
      end
    end
    it 'should give back the input names and values' do
      cookie = Cookie.from_set_cookie 'http://localhost/', 'foo=bar'
      expect(cookie.name).to eq 'foo'
      expect(cookie.value).to eq 'bar'
    end
    it 'should normalize domain names' do
      cookie = Cookie.from_set_cookie 'http://localhost/', 'foo=Bar;domain=LoCaLHoSt.local'
      expect(cookie.domain).to eq '.localhost.local'
    end
    it 'should accept non-normalized .local' do
      cookie = Cookie.from_set_cookie 'http://localhost/', 'foo=bar;domain=.local'
      expect(cookie.domain).to eq '.local'
    end
    it 'should accept secure cookies' do
      cookie = Cookie.from_set_cookie 'https://www.google.com/a/blah', 'GALX=RgmSftjnbPM;Path=/a/;Secure'
      expect(cookie.name).to eq 'GALX'
      expect(cookie.secure).to be_truthy
    end
  end
  describe '#from_set_cookie2' do
    it 'should give back the input names and values' do
      cookie = Cookie.from_set_cookie2 'http://localhost/', 'foo=bar;Version=1'
      expect(cookie.name).to eq 'foo'
      expect(cookie.value).to eq 'bar'
    end
    it 'should normalize domain names' do
      cookie = Cookie.from_set_cookie2 'http://localhost/', 'foo=Bar;domain=LoCaLHoSt.local;Version=1'
      expect(cookie.domain).to eq '.localhost.local'
    end
    it 'should accept non-normalized .local' do
      cookie = Cookie.from_set_cookie2 'http://localhost/', 'foo=bar;domain=.local;Version=1'
      expect(cookie.domain).to eq '.local'
    end
    it 'should accept secure cookies' do
      cookie = Cookie.from_set_cookie2 'https://www.google.com/a/blah', 'GALX=RgmSftjnbPM;Path="/a/";Secure;Version=1'
      expect(cookie.name).to eq 'GALX'
      expect(cookie.path).to eq '/a/'
      expect(cookie.secure).to be_truthy
    end
    it 'should fail on unquoted paths' do
      expect {
        Cookie.from_set_cookie2 'https://www.google.com/a/blah',
                                'GALX=RgmSftjnbPM;Path=/a/;Secure;Version=1'
      }.to raise_error InvalidCookieError
    end
    it 'should accept quoted values' do
      cookie = Cookie.from_set_cookie2 'http://localhost/', 'foo="bar";Version=1'
      expect(cookie.name).to eq 'foo'
      expect(cookie.value).to eq '"bar"'
    end
    it 'should accept poorly chosen names' do
      cookie = Cookie.from_set_cookie2 'http://localhost/', 'Version=mine;Version=1'
      expect(cookie.name).to eq 'Version'
      expect(cookie.value).to eq 'mine'
    end
    it 'should accept quoted parameter values' do
      Cookie.from_set_cookie2 'http://localhost/', 'foo=bar;Version="1"'
    end
    it 'should honor the discard and max-age parameters' do
      cookie = Cookie.from_set_cookie2 'http://localhost/', 'f=b;max-age=100;discard;Version=1'
      expect(cookie).to be_session
      expect(cookie).to_not be_expired

      cookie = Cookie.from_set_cookie2 'http://localhost/', 'f=b;max-age=100;Version=1'
      expect(cookie).to_not be_session

      cookie = Cookie.from_set_cookie2 'http://localhost/', 'f=b;Version=1'
      expect(cookie).to be_session
    end
    it 'should handle quotable quotes' do
      cookie = Cookie.from_set_cookie2 'http://localhost/', 'f="\"";Version=1'
      expect(cookie.value).to eq '"\""'
    end
    it 'should handle quotable apostrophes' do
      cookie = Cookie.from_set_cookie2 'http://localhost/', 'f="\;";Version=1'
      expect(cookie.value).to eq '"\;"'
    end
  end
  describe '#decoded_value' do
    it 'should leave normal values alone' do
      cookie = Cookie.from_set_cookie2 'http://localhost/', 'f=b;Version=1'
      expect(cookie.decoded_value).to eq 'b'
    end
    it 'should attempt to unencode quoted values' do
      cookie = Cookie.from_set_cookie2 'http://localhost/', 'f="\"b";Version=1'
      expect(cookie.value).to eq '"\"b"'
      expect(cookie.decoded_value).to eq '"b'
    end
  end
  describe '#to_s' do
    it 'should handle a simple cookie' do
      cookie = Cookie.from_set_cookie 'http://localhost/', 'f=b'
      expect(cookie.to_s).to eq 'f=b'
      expect(cookie.to_s(1)).to eq '$Version=0;f=b;$Path="/"'
    end
    it 'should report an explicit domain' do
      cookie = Cookie.from_set_cookie2 'http://localhost/', 'f=b;Version=1;Domain=.local'
      expect(cookie.to_s(1)).to eq '$Version=1;f=b;$Path="/";$Domain=.local'
    end
    it 'should return specified ports' do
      cookie = Cookie.from_set_cookie2 'http://localhost/', 'f=b;Version=1;Port="80,443"'
      expect(cookie.to_s(1)).to eq '$Version=1;f=b;$Path="/";$Port="80,443"'
    end
    it 'should handle specified paths' do
      cookie = Cookie.from_set_cookie 'http://localhost/bar/', 'f=b;path=/bar/'
      expect(cookie.to_s).to eq 'f=b'
      expect(cookie.to_s(1)).to eq '$Version=0;f=b;$Path="/bar/"'
    end
    it 'should omit $Version header when asked' do
      cookie = Cookie.from_set_cookie 'http://localhost/', 'f=b'
      expect(cookie.to_s(1, false)).to eq 'f=b;$Path="/"'
    end
  end
  describe '#should_send?' do
    it 'should not send if ports do not match' do
      cookie = Cookie.from_set_cookie2 'http://localhost/', 'f=b;Version=1;Port="80"'
      expect(cookie.should_send?('http://localhost/', false)).to be_truthy
      expect(cookie.should_send?('https://localhost/', false)).to be_falsey
    end
  end
  begin
    require 'json'
    describe '.to_json' do
      it 'should serialize a cookie to JSON' do
        c = Cookie.from_set_cookie 'https://localhost/', 'foo=bar;secure;expires=Fri, September 11 2009 18:10:00 -0700'
        json = c.to_json
        expect(json).to be_a String
      end
    end
    describe '.json_create' do
      it 'should deserialize JSON to a cookie' do
        json = '{"name":"foo","value":"bar","domain":"localhost.local","path":"\\/","created_at":"2009-09-11 12:51:03 -0600","expiry":"2009-09-11 19:10:00 -0600","secure":true}'
        hash = JSON.parse json
        c = Cookie.json_create hash
        CookieValidation.validate_cookie 'https://localhost/', c
      end
      it 'should automatically deserialize to a cookie' do
        json = '{"json_class":"CookieJar::Cookie","name":"foo","value":"bar","domain":"localhost.local","path":"\\/","created_at":"2009-09-11 12:51:03 -0600","expiry":"2009-09-11 19:10:00 -0600","secure":true}'
        c = JSON.parse json, create_additions: true
        expect(c).to be_a Cookie
        CookieValidation.validate_cookie 'https://localhost/', c
      end
    end
  rescue LoadError
    it 'does not appear the JSON library is installed' do
      raise 'please install the JSON library'
    end
  end
end
