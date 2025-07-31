# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

%w[rspec rspec-core rspec-expectations rspec-mocks rspec-support].each do |lib|
  branch = ENV.fetch('BRANCH', 'main')
  library_path = File.expand_path("../../#{lib}", __FILE__)

  if File.exist?(library_path) && !ENV['USE_GIT_REPOS']
    gem lib, path: library_path
  elsif lib == 'rspec'
    gem 'rspec', git: "https://github.com/rspec/rspec-metagem.git", branch: branch
  else
    gem lib, git: "https://github.com/rspec/#{lib}.git", branch: branch
  end
end

gem 'aruba', '~> 2.2.0'
gem 'bundler', '> 2.0.0'
gem 'coveralls', require: false
gem 'cucumber', '>= 1.3.8'
gem 'ffi', '~> 1.17.0'
gem 'matrix', '~> 0.4.2'
gem 'rake', '~> 13.2.0'
gem 'rubocop', '~> 1.68.0'
