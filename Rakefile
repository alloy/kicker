require 'rubygems'
require 'bundler/setup'

require 'rake/testtask'
require 'rdoc/task'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "kicker"
    gem.summary = %Q{A lean, agnostic, flexible file-change watcher, using OS X FSEvents.}
    gem.email = "eloy.de.enige@gmail.com"
    gem.homepage = "http://github.com/alloy/kicker"
    gem.authors = ["Eloy Duran"]
    gem.files.concat FileList['vendor/**/*']
    gem.require_paths = ["lib", "vendor"]
    gem.has_rdoc = true
    gem.add_dependency 'rb-fsevent'
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler -s http://gems.github.com"
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
end

namespace :docs do
  Rake::RDocTask.new('generate') do |t|
    t.main = "README.rdoc"
    t.rdoc_files.include("README.rdoc", "lib/**/*.rb")
    t.options << '--charset=utf8'
  end
end

task :default => :test
