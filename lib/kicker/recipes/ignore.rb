module Ignore
  def self.call(files)
    files.reject! { |file| ignores.any? { |ignore| file =~ ignore } }
  end
  
  def self.ignores
    @ignores ||= []
  end
  
  def self.ignore(regexp_or_string)
    ignores << (regexp_or_string.is_a?(Regexp) ? regexp_or_string : /^#{regexp_or_string}$/)
  end
end

module Kernel
  def ignore(regexp_or_string)
    Ignore.ignore(regexp_or_string)
  end
end

pre_process Ignore

ignore("tmp")
ignore(/\w+\.log/)
ignore(/\.(svn|git)\//)
ignore("svn-commit.tmp")