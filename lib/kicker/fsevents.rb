# encoding: utf-8

require 'listen'

class Kicker
  class FSEvents
    class FSEvent
      attr_reader :path

      def initialize(path)
        @path = path
      end

      def files
        Dir.glob("#{File.expand_path(path)}/*").map do |filename|
          begin
            [File.mtime(filename), filename]
          rescue Errno::ENOENT
            nil
          end
        end.compact.sort.reverse.map { |_, filename| filename }
      end
    end

    def self.start_watching(paths, options={}, &block)
      listener = Listen.to(*(paths.dup << options)) do |modified, added, removed|
        files = modified + added + removed
        directories = files.map { |file| File.dirname(file) }.uniq
        yield directories.map { |directory| Kicker::FSEvents::FSEvent.new(directory) }
      end
      listener.start
      listener
    end
  end
end
