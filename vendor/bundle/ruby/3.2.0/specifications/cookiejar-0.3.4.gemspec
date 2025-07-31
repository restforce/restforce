# -*- encoding: utf-8 -*-
# stub: cookiejar 0.3.4 ruby lib

Gem::Specification.new do |s|
  s.name = "cookiejar".freeze
  s.version = "0.3.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["David Waite".freeze]
  s.date = "2014-02-01"
  s.description = "Allows for parsing and returning cookies in Ruby HTTP client code".freeze
  s.email = ["david@alkaline-solutions.com".freeze]
  s.homepage = "http://alkaline-solutions.com".freeze
  s.licenses = ["BSD-2-Clause".freeze]
  s.rdoc_options = ["--title".freeze, "CookieJar -- Client-side HTTP Cookies".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Client-side HTTP Cookie library".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<rake>.freeze, [">= 10.0"])
  s.add_development_dependency(%q<rspec-collection_matchers>.freeze, ["~> 1.0"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
  s.add_development_dependency(%q<yard>.freeze, ["~> 0.9.20"])
  s.add_development_dependency(%q<bundler>.freeze, [">= 0.9.3"])
end
