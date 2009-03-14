# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{kicker}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Eloy Duran"]
  s.date = %q{2009-03-14}
  s.default_executable = %q{kicker}
  s.email = %q{eloy.de.enige@gmail.com}
  s.executables = ["kicker"]
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.files = ["bin", "bin/kicker", "kicker.gemspec", "LICENSE", "pkg", "pkg/kicker-0.1.0.gem", "Rakefile", "README.rdoc", "vendor", "vendor/rucola", "vendor/rucola/fsevents.rb", "VERSION.yml"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/alloy/kicker}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["vendor"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A simple OS X CLI tool which uses FSEvents to run a given shell command.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
