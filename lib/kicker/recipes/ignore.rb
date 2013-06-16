# A recipe which removes files from the files array, thus “ignoring” them.
#
# By default ignores logs, tmp, and svn and git files.
#
# See Kernel#ignore for info on how to ignore files.
module Ignore
  def self.call(files) #:nodoc:
    files.reject! { |file| ignores.any? { |ignore| file =~ ignore } }
  end

  def self.ignores #:nodoc:
    @ignores ||= []
  end

  def self.ignore(regexp_or_string) #:nodoc:
    ignores << (regexp_or_string.is_a?(Regexp) ? regexp_or_string : /^#{regexp_or_string}$/)
  end
end

module Kernel
  # Adds +regexp_or_string+ as an ignore rule.
  #
  #   require 'ignore'
  #
  #   ignore /^data\//
  #   ignore 'Rakefile'
  #
  # <em>Only available if the `ignore' recipe is required.</em>
  def ignore(regexp_or_string)
    Ignore.ignore(regexp_or_string)
  end
end

recipe :ignore do
  pre_process Ignore

  ignore("tmp")
  ignore(/\w+\.log/)
  ignore(/\.(svn|git)\//)
  ignore("svn-commit.tmp")
end
