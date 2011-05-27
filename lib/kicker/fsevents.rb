# encoding: utf-8

require 'rb-fsevent'

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
      fsevent = ::FSEvent.new
      fsevent.watch(paths, options) do |directories|
        yield directories.map { |directory| Kicker::FSEvents::FSEvent.new(directory) }
      end
      fsevent.run
    end
  end
end