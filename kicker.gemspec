# -*- encoding: utf-8 -*-
$:.unshift File.expand_path('../lib', __FILE__)
require 'kicker/version'

Gem::Specification.new do |s|
  s.name     = "kicker"
  s.version  = Kicker::VERSION
  s.date     = Date.today

  s.summary  = "A lean, agnostic, flexible file-change watcher."
  s.authors  = ["Eloy Duran", "Manfred Stienstra"]
  s.homepage = "http://github.com/alloy/kicker"
  s.email    = %w{ eloy.de.enige@gmail.com manfred@fngtps.com }

  s.executables      = %w{ kicker }
  s.require_paths    = %w{ lib vendor }
  s.files            = Dir['bin/kicker',
                           'lib/**/*.rb',
                           'vendor/terminal-notifier_v1.0/**/*',
                           'README.rdoc',
                           'LICENSE',
                           'html/images/kikker.jpg']
  s.extra_rdoc_files = %w{ LICENSE README.rdoc }

  s.add_runtime_dependency("listen", '~> 1.1.0')
  s.add_runtime_dependency("terminal-notifier")

  s.add_development_dependency("rake")

  s.add_development_dependency("bacon")
  s.add_development_dependency("mocha")
  s.add_development_dependency("mocha-on-bacon")
  s.add_development_dependency("activesupport")
end

