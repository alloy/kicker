class Kicker
  module ArrayExt
    # Deletes elements from self for which the block evaluates to +true+. A new
    # array is returned with those values the block returned.
    #
    # Basically, a combination of reject! and map.
    #
    #   a = [1,2,3]
    #   b = a.take_and_map { |x| x * 2 if x == 2 }
    #   b # => [4]
    #   a # => [1, 3]
    def take_and_map
      took = []
      reject! do |x|
        if result = yield(x)
          took << result
        end
      end
      took
    end
  end
end

Array.send(:include, Kicker::ArrayExt)