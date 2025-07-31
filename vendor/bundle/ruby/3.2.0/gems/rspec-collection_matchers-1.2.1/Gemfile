source 'https://rubygems.org'

gemspec

%w[rspec rspec-support rspec-core rspec-expectations rspec-mocks].each do |lib|
  library_path = File.expand_path("../../#{lib}", __FILE__)
  if File.exist?(library_path) && !ENV['USE_GIT_REPOS']
    gem lib, :path => library_path
  else
    gem lib, :git => "https://github.com/rspec/#{lib}.git", :branch => ENV.fetch('BRANCH', 'main')
  end
end

gem "aruba"

if RUBY_VERSION < '1.9.3'
  gem "rake", "~> 10.0.0" # rake 11 requires Ruby 1.9.3 or later
elsif RUBY_VERSION < '2.0.0'
  gem "rake", "~> 11.0.0" # rake 12 requires Ruby 2.0.0 or later
elsif RUBY_VERSION < '2.2.0'
  gem "rake", "~> 12.3.2" # rake 13 requires Ruby 2.2.0 or later
else
  gem "rake", "~> 13.0.0"
end

version_file = File.expand_path("../.rails-version", __FILE__)
rails_gem_args = case version = ENV['RAILS_VERSION'] || (File.exist?(version_file) && File.read(version_file).chomp)
when /main/
 { :git => "git://github.com/rails/rails.git" }
when /stable$/
 { :git => "git://github.com/rails/rails.git", :branch => version }
when nil, false, ""
  if RUBY_VERSION < '1.9.3'
    # Rails 4+ requires 1.9.3+, so on earlier versions default to the last 3.x release.
     "3.2.17"
  else
    "4.0.4"
  end
else
  version
end

gem "activesupport", *rails_gem_args
gem "activemodel",   *rails_gem_args

if RUBY_VERSION.to_f < 2
  gem "cucumber", "~> 1.3.20"
  gem "contracts", "0.15.0" # doesn't work on Ruby 1.9.3
  gem 'json', '< 2'
  gem 'term-ansicolor',  '< 1.4.0' # used by cucumber
  gem 'tins', '~> 1.6.0' # used by term-ansicolor
else
  gem "cucumber"
  gem "json", "> 2.3.0"
end

if RUBY_VERSION < '1.9.3'
  gem 'i18n', '< 0.7.0'
end

eval File.read('Gemfile-custom') if File.exist?('Gemfile-custom')
