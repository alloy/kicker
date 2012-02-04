NAME = 'Kicker'
LOWERCASE_NAME = NAME.downcase
GEM_NAME = LOWERCASE_NAME

def gem_version
  require File.expand_path("../../lib/#{LOWERCASE_NAME}/version", __FILE__)
  Object.const_get(NAME).const_get('VERSION')
end

def gem_file
  "#{GEM_NAME}-#{gem_version}.gem"
end

desc "Build gem"
task :build do
  sh "gem build #{GEM_NAME}.gemspec"
end

desc "Clean gems"
task :clean do
  sh "rm -f *.gem"
end

desc "Install gem"
task :install => :build do
  sh "sudo gem install #{gem_file}"
end

desc "Clean, build, install, and push gem to rubygems.org"
task :release => [:clean, :install] do
  sh "git tag -a #{gem_version} -m 'Release #{gem_version}'"
  sh "git push --tags"
  sh "gem push #{gem_file}"
end
