class Kicker
  module ArrayExt
    # Deletes elements from self for which the block evaluates to +true+. A new
    # array is returned with those values the block returned. So basically, a
    # combination of reject! and map.
    #
    #   a = [1,2,3]
    #   b = a.take_and_map { |x| x * 2 if x == 2 }
    #   b # => [4]
    #   a # => [1, 3]
    #
    # If +pattern+ is specified then files matching the pattern will be taken.
    #
    #   a = [ 'bar', 'foo/bar' ]
    #   b = a.take_and_map('*/bar') { |x| x }
    #   b # => ['foo/bar']
    #   a # => ['bar']
    #
    # If +flatten_and_compact+ is +true+, the result array will be flattened
    # and compacted. The default is +true+.
    def take_and_map(pattern = nil, flatten_and_compact = true)
      took = []
      reject! do |x|
        next if pattern and !File.fnmatch?(pattern, x)
        if result = yield(x)
          took << result
        end
      end
      if flatten_and_compact
        took.flatten!
        took.compact!
      end
      took
    end
  end
end

Array.send(:include, Kicker::ArrayExt)