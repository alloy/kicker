class Kicker
  class CallbackChain < Array
    alias_method :append_callback,  :push
    alias_method :prepend_callback, :unshift
    
    def call(files)
      each do |callback|
        break if files.empty?
        callback.call(files)
      end
    end
  end
  
  class << self
    def pre_process_chain
      @pre_process_chain ||= CallbackChain.new
    end
    
    def process_chain
      @process_chain ||= CallbackChain.new
    end
    
    def post_process_chain
      @post_process_chain ||= CallbackChain.new
    end
    
    def full_chain
      @full_chain ||= CallbackChain.new([pre_process_chain, process_chain, post_process_chain])
    end
  end
  
  def pre_process_chain
    self.class.pre_process_chain
  end
  
  def process_chain
    self.class.process_chain
  end
  
  def post_process_chain
    self.class.post_process_chain
  end
  
  def full_chain
    self.class.full_chain
  end
end

module Kernel
  private
  
  def pre_process_callback(callback = nil, &block)
    Kicker.pre_process_chain.append_callback(block ? block : callback)
  end
  
  def process_callback(callback = nil, &block)
    Kicker.process_chain.append_callback(block ? block : callback)
  end
  
  def post_process_callback(callback = nil, &block)
    Kicker.post_process_chain.prepend_callback(block ? block : callback)
  end
end