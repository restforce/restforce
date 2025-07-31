require 'bundler/gem_tasks'

require 'rake'

require 'rake/clean'
require 'yard'
require 'yard/rake/yardoc_task'

CLEAN << Rake::FileList['doc/**', '.yardoc']
# Yard
YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb'] # optional
  t.options = ['--title', 'CookieJar, a HTTP Client Cookie Parsing Library',
               '--main', 'README.markdown', '--files', 'LICENSE']
end

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new do |t|
    t.ruby_opts = %w(-w)
    t.pattern = 'spec/**/*_spec.rb'
  end
  task test: :spec
rescue LoadError
  puts 'Warning: unable to load rspec tasks'
end

# Default Rake task is to run all tests
task default: :test
