class Kicker
  class CallbackChain < Array #:nodoc:
    alias_method :append_callback,  :push
    alias_method :prepend_callback, :unshift
    
    def call(files, stop_when_empty = true)
      each do |callback|
        break if stop_when_empty and files.empty?
        callback.call(files)
      end
    end
  end
  
  class << self
    attr_writer :startup_chain
    def startup_chain
      @startup_chain ||= CallbackChain.new
    end
    
    attr_writer :pre_process_chain
    def pre_process_chain
      @pre_process_chain ||= CallbackChain.new
    end
    
    attr_writer :process_chain
    def process_chain
      @process_chain ||= CallbackChain.new
    end
    
    attr_writer :post_process_chain
    def post_process_chain
      @post_process_chain ||= CallbackChain.new
    end
    
    attr_writer :full_chain
    def full_chain
      @full_chain ||= CallbackChain.new([pre_process_chain, process_chain, post_process_chain])
    end
  end
  
  def startup_chain
    self.class.startup_chain
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
  # Adds a handler to the startup chain. This chain is ran once Kicker is done
  # loading _before_ starting the normal operations. Note that an empty files
  # array is given to the callback.
  #
  # Takes a +callback+ object that responds to <tt>#call</tt>, or a block.
  def startup(callback = nil, &block)
    Kicker.startup_chain.append_callback(block ? block : callback)
  end
  
  # Adds a handler to the pre_process chain. This chain is ran before the
  # process chain and is processed from first to last.
  #
  # Takes a +callback+ object that responds to <tt>#call</tt>, or a block.
  def pre_process(callback = nil, &block)
    Kicker.pre_process_chain.append_callback(block ? block : callback)
  end
  
  # Adds a handler to the process chain. This chain is ran in between the
  # pre_process and post_process chains. It is processed from first to last.
  #
  # Takes a +callback+ object that responds to <tt>#call</tt>, or a block.
  def process(callback = nil, &block)
    Kicker.process_chain.append_callback(block ? block : callback)
  end
  
  # Adds a handler to the post_process chain. This chain is ran after the
  # process chain and is processed from last to first.
  #
  # Takes a +callback+ object that responds to <tt>#call</tt>, or a block.
  def post_process(callback = nil, &block)
    Kicker.post_process_chain.prepend_callback(block ? block : callback)
  end
end