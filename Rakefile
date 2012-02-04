require 'rubygems'
require 'bundler/setup'

require 'rdoc/task'

desc "Run tests"
task :test do
  # shuffle to ensure that tests are run in different order
  files = FileList['test/**/*_test.rb'].map { |f| f[0,f.size-3] }.shuffle
  sh "ruby -Ilib -I. -r '#{files.join("' -r '")}' -e ''"
end

namespace :docs do
  Rake::RDocTask.new('generate') do |t|
    t.main = "README.rdoc"
    t.rdoc_files.include("README.rdoc", "lib/**/*.rb")
    t.options << '--charset=utf8'
  end
end

task :default => :test
