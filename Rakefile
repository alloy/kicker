require 'rdoc/task'

desc "Run specs"
task :spec do
  # shuffle to ensure that tests are run in different order
  files = FileList['spec/**/*_spec.rb'].shuffle
  sh "bundle exec bacon #{files.map { |file| "'#{file}'" }.join(' ')}"
end

namespace :docs do
  RDoc::Task.new('generate') do |t|
    t.main = "README.rdoc"
    t.rdoc_files.include("README.rdoc", "lib/**/*.rb")
    t.options << '--charset=utf8'
  end
end

task :docs => 'docs:generate' do
  FileUtils.cp_r('images', 'html')
end

task :default => :spec
