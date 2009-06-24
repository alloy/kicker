class Kicker
  class CallbackChain < Array
    alias_method :append_callback,  :push
    alias_method :prepend_callback, :unshift
    
    def run(files)
      each do |callback|
        files = callback.call(files)
        break if !files.is_a?(Array) || files.empty?
      end
    end
  end
  
  def self.callback_chain
    @callback_chain ||= CallbackChain.new
  end
end