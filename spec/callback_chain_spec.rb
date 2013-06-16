require File.expand_path('../spec_helper', __FILE__)

describe "Kicker, concerning its callback chains" do
  before do
    @chains = [:startup_chain, :pre_process_chain, :process_chain, :post_process_chain, :full_chain]
  end

  it "should return the callback chain instances" do
    @chains.each do |chain|
      Kicker.send(chain).should.be.instance_of Kicker::CallbackChain
    end
  end

  it "should be accessible by an instance" do
    kicker = Kicker.new

    @chains.each do |chain|
      kicker.send(chain).should == Kicker.send(chain)
    end
  end

  it "should provide a shortcut method which appends a callback to the startup chain" do
    Kicker.startup_chain.expects(:append_callback).with do |callback|
      callback.call == :from_callback
    end

    startup { :from_callback }
  end

  it "should provide a shortcut method which appends a callback to the pre-process chain" do
    Kicker.pre_process_chain.expects(:append_callback).with do |callback|
      callback.call == :from_callback
    end

    pre_process { :from_callback }
  end

  it "should provide a shortcut method which appends a callback to the process chain" do
    Kicker.process_chain.expects(:append_callback).with do |callback|
      callback.call == :from_callback
    end

    process { :from_callback }
  end

  it "should provide a shortcut method which prepends a callback to the post-process chain" do
    Kicker.post_process_chain.expects(:prepend_callback).with do |callback|
      callback.call == :from_callback
    end

    post_process { :from_callback }
  end

  it "should have assigned the chains to the `full_chain' (except startup_chain)" do
    Kicker.full_chain.length.should == 3
    Kicker.full_chain.each_with_index do |chain, index|
      chain.should == Kicker.send(@chains[index + 1])
    end
  end
end

describe "Kicker::CallbackChain" do
  it "should be a subclass of Array" do
    Kicker::CallbackChain.superclass.should == Array
  end
end

describe "An instance of Kicker::CallbackChain, concerning it's API" do
  before do
    @chain = Kicker::CallbackChain.new

    @callback1 = lambda {}
    @callback2 = lambda {}
  end

  it "should append a callback" do
    @chain << @callback1
    @chain.append_callback(@callback2)

    @chain.should == [@callback1, @callback2]
  end

  it "should prepend a callback" do
    @chain << @callback1
    @chain.prepend_callback(@callback2)

    @chain.should == [@callback2, @callback1]
  end
end

describe "An instance of Kicker::CallbackChain, when calling the chain" do
  before do
    @chain = Kicker::CallbackChain.new
    @result = []
  end

  it "should call the callbacks from first to last" do
    @chain.append_callback lambda { |files| @result << 1 }
    @chain.append_callback lambda { |files| @result << 2 }
    @chain.call(%w{ file })
    @result.should == [1, 2]
  end

  it "should pass the files array given to #call to each callback in the chain" do
    array = %w{ /file/1 }

    @chain.append_callback lambda { |files|
      files.should == array
      files.concat(%w{ /file/2 })
    }

    @chain.append_callback lambda { |files|
      files.should == array
      @result.concat(files)
    }

    @chain.call(array)
    @result.should == %w{ /file/1 /file/2 }
  end

  it "should halt the callback chain once the given array is empty" do
    @chain.append_callback lambda { |files| @result << 1; files.clear }
    @chain.append_callback lambda { |files| @result << 2 }
    @chain.call(%w{ /file/1 /file/2 })
    @result.should == [1]
  end

  it "should not halt the chain if the array is empty if specified" do
    @chain.append_callback lambda { |files| @result << 1; files.clear }
    @chain.append_callback lambda { |files| @result << 2 }
    @chain.call(%w{ /file/1 /file/2 }, false)
    @result.should == [1, 2]
  end

  it "should not call any callback if the given array is empty" do
    @chain.append_callback lambda { |files| @result << 1 }
    @chain.call([])
    @result.should == []
  end

  it "should work with a chain of chains as well" do
    array = %w{ file }

    kicker_and_files = lambda do |kicker, files|
      kicker.should.be @kicker
      files.should.be array
    end

    chain1 = Kicker::CallbackChain.new([
      lambda { |files| files.should == array; @result << 1 },
      lambda { |files| files.should == array; @result << 2 }
    ])

    chain2 = Kicker::CallbackChain.new([
      lambda { |files| files.should == array; @result << 3 },
      lambda { |files| files.should == array; @result << 4 }
    ])

    @chain.append_callback chain1
    @chain.append_callback chain2

    @chain.call(array)
    @result.should == [1, 2, 3, 4]
  end
end
