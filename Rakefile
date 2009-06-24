require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "kicker"
    gem.summary = %Q{A simple OS X CLI tool which uses FSEvents to run a given shell command.}
    gem.email = "eloy.de.enige@gmail.com"
    gem.homepage = "http://github.com/alloy/kicker"
    gem.authors = ["Eloy Duran"]
    gem.executables << 'kicker'
    gem.files.concat FileList['vendor/**/*']
    gem.require_paths = ["lib", "vendor"]
    gem.has_rdoc = true
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.options = '-rs'
end

namespace :docs do
  Rake::RDocTask.new('generate') do |t|
    t.main = "README.rdoc"
    t.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  end
end

task :default => :test