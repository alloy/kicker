require 'rubygems'
require 'bundler/setup'

require 'rake/testtask'
require 'rdoc/task'

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
