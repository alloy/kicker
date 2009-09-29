module Watchr
  class << self
    def watchers
      @watchers ||= []
    end
    
    def eval_watchers(string)
      instance_eval string
    end
  end
end