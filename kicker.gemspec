# -*- encoding: utf-8 -*-
$:.unshift File.expand_path('../lib', __FILE__)
require 'kicker/version'

Gem::Specification.new do |s|
  s.name     = "kicker"
  s.version  = Kicker::VERSION
  s.date     = Time.new

  s.summary  = "A lean, agnostic, flexible file-change watcher."
  s.description = "Allows you to fire specific command on file-system change."
  s.authors  = ["Eloy Duran", "Manfred Stienstra"]
  s.homepage = "http://github.com/alloy/kicker"
  s.email    = %w{ eloy.de.enige@gmail.com manfred@fngtps.com }

  s.executables      = %w{ kicker }
  s.require_paths    = %w{ lib vendor }
  s.files            = Dir['bin/kicker',
                           'lib/**/*.rb',
                           'README.rdoc',
                           'LICENSE',
                           'html/images/kikker.jpg']
  s.extra_rdoc_files = %w{ LICENSE README.rdoc }

  s.post_install_message = %{
    For multi platform notifications install notification gem for your platform.
    For the list of supported gems see https://github.com/jugyo/notify#feature
  }

  s.add_runtime_dependency("listen", '~> 1.1.0')
  s.add_runtime_dependency("notify", '~> 0.5.1')

  s.add_development_dependency("bacon")
  s.add_development_dependency("mocha-on-bacon")
  s.add_development_dependency("activesupport")
  s.add_development_dependency("fakefs")
end

