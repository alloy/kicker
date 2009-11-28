require 'rubygems'
require 'test/spec'
require 'mocha'

$:.unshift File.expand_path('../../lib', __FILE__)
require 'kicker'
Kicker::Utils.quiet = true