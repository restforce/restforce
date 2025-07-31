# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "em-socksify/version"

Gem::Specification.new do |s|
  s.name        = "em-socksify"
  s.version     = EventMachine::Socksify::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ilya Grigorik"]
  s.email       = ["ilya@igvita.com"]
  s.homepage    = "https://github.com/igrigorik/em-socksify"
  s.summary     = "Transparent proxy support for any EventMachine protocol"
  s.description = s.summary
  s.license     = "MIT"

  s.rubyforge_project = "em-socksify"

  s.add_dependency "base64"
  s.add_dependency "eventmachine", ">= 1.0.0.beta.4"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
