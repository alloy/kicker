require 'rubygems'
require 'rake'
require 'rake/testtask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "kicker"
    gem.summary = %Q{A simple OS X CLI tool which uses FSEvents to run a given shell command.}
    gem.email = "eloy.de.enige@gmail.com"
    gem.homepage = "http://github.com/alloy/kicker"
    gem.authors = ["Eloy Duran"]
    gem.executables << 'kicker'
    gem.files = FileList['**/**']
    gem.require_paths = ['vendor']
    gem.has_rdoc = false
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
  t.options = '-rs'
end

task :default => :test