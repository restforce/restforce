# -*- encoding: utf-8 -*-
# stub: faraday-typhoeus 1.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "faraday-typhoeus".freeze
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/dleavitt/faraday-typhoeus", "homepage_uri" => "https://github.com/dleavitt/faraday-typhoeus", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/dleavitt/faraday-typhoeus" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Daniel Leavitt".freeze]
  s.date = "2023-10-25"
  s.description = "Faraday adapter for Typhoeus".freeze
  s.email = ["daniel.leavitt@gmail.com".freeze]
  s.homepage = "https://github.com/dleavitt/faraday-typhoeus".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Faraday adapter for Typhoeus".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<faraday>.freeze, ["~> 2.0"])
  s.add_runtime_dependency(%q<typhoeus>.freeze, ["~> 1.4"])
end
